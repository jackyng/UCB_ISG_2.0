class QueryController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  before_filter :check_admin_privilege

  def index
    @queries = @admin.queries
  end

  def create
    if request.method == "POST"
      unless params[:description]
        flash[:error] = "Description required!"
        return
      end
      unless params[:query_string]
        flash[:error] = "SQL query string required!"
        return
      end
      query = @admin.queries.new(description: params[:description], query_string: params[:query_string])
      if query.save
        flash[:notice] = "Query successfully saved"
        redirect_to query_path
      else
        flash[:error] = query.errors.map {|k,v| "#{k.to_s} error: #{v}"}.join(". ")
      end
    end
  end


  def edit
    begin
      @query = Query.find(params[:id])
      return if is_not_owner("edit") { redirect_to query_path }
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Could not find query with id '#{params[:id]}'"
      return
    end

    if request.method == "POST"
      unless params[:description]
        flash[:error] = "Description required!"
        return
      end
      unless params[:query_string]
        flash[:error] = "SQL query string required!"
        return
      end

      if @query.update_attributes(description: params[:description], query_string: params[:query_string])
        flash[:notice] = "Successfully updated query"
        redirect_to query_path and return
      else
        flash[:error] = "Can't update query because:\n"
        flash[:error] << @query.errors.map {|k,v| "#{k.to_s} error: #{v}"}.join(". ")
      end
    end
  end
 
  def destroy
    begin
      @query = Query.find(params[:id])
      return if is_not_owner("destroy") { redirect_to query_path }
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Could not find query with id '#{params[:id]}'"
      redirect_to query_path and return
    end

    if request.method == "DELETE"
      if @query.destroy
        flash[:notice] = "Successfully removed query '#{@query.description}'."
      else
        flash[:error] = "Can't delete query because:\n"
        flash[:error] << @query.errors.map {|k,v| "#{k.to_s} error: #{v}"}.join(". ")
      end
    end
    redirect_to query_path
  end

  def run
    if params[:id]
      begin
        @query = Query.find(params[:id])
        return if is_not_owner("run")
        params[:query_string] = @query.query_string
      rescue
        flash[:error] = "Could not find query with id '#{params[:id]}'"
        respond_to do |format|
          format.json { render json: {error: flash[:error]} }
          format.html { redirect_to query_path }
        end
        return
      end
    end

    if request.method == "POST"
      if params[:query_string]
        db_conn = ActiveRecord::Base.connection()
        begin
          @results = db_conn.execute(params[:query_string])
        rescue Exception => error
          flash[:error] = error.message
          respond_to do |format|
            format.json { render json: {error: flash[:error]} }
            format.html
          end
          return
        end
        json = { results: @results }
        json[:headers] = @results.fields if @results
        respond_to do |format|
          format.json { render json: json }
          format.html
        end
      else
        flash[:error] = "Query string required"
      end
    end
  end

  def is_not_owner(action)
    if @query.admin_id != @admin.id
      flash[:error] = "You cannot #{action} a query belongs to another admin"
      respond_to do |format|
        format.json { render json: {error: flash[:error]} }
        format.html { yield if block_given? }
      end
      return true
    end
    return false
  end
end

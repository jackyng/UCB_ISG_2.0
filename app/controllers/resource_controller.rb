class ResourceController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :check_admin_privilege
  
  def create
    unless params[:node_id]
      flash[:error] = "Required a parent id to create a subtopic"
      redirect_to :root and return
    end
    begin
      @node = Node.find(params[:node_id])
    rescue
      flash[:error] = "Invalid parent id '#{params[:node_id]}' to create subtopic"
      redirect_to :root and return
    end

    if params[:name] and params[:url]
      @resource = @node.resources.new(:name => params[:name], :url => params[:url])

      if @resource.save
        flash[:notice] = "Resource created"
        flash[:error] = ""
        redirect_to :root
      else
        if not Resource.find_by_name(params[:name]).blank?
          flash[:error] = "Another resource with same name already created!"
        elsif not Resource.find_by_url(params[:url]).blank?
          flash[:error] = "Another resource with same url already created!"
        else
          flash[:error] = "Please check your name '#{params[:name]}' and/or url '#{params[:url]}'"
        end
        flash[:notice] = ""
      end
    end
  end

  def edit
    begin
      @resource = Resource.find(params[:id])
    rescue
      flash[:error] = "Need a valid resource id to edit; got '#{params[:id]}'"
      redirect_to :root and return
    end

    updated = false
    if params[:name] and params[:url]
      if @resource.update_attributes(name: params[:name], url: params[:url])
        updated = true
      end
    elsif params[:name]
      if @resource.update_attributes(name: params[:name])
        updated = true
      end
    elsif params[:url]
      if @resource.update_attributes(url: params[:url])
        updated = true
      end
    end

    if updated
      flash[:notice] = "Resource updated with name '#{@resource.name}' and url '#{@resource.url}'"
      redirect_to :root
    else
      flash[:error] = @resource.errors.map {|k,v| "#{k.to_s} error: #{v}"}.join(". ")
    end
  end

  def destroy
    @resource = Resource.find(params[:id])
    node_id = @resource.node_id
    if @resource.destroy
      flash[:notice] = "Resource removed"
    else
      flash[:error] = "Please try again"
    end
    redirect_to :root
  end
end

class ResourceController < ApplicationController
  def create
    if params[:node_id].nil?
      redirect_to root_url and return
    end
    if params[:name].nil? or params[:url].nil?
      render :create and return
    end

    @node = Node.find(params[:node_id])
    @resource = @node.resources.new(:name => params[:name], :url => params[:url], :count => 0)
    if @resource.save
      flash[:notice] = "Resource created"
      flash[:error] = ""
      redirect_to node_path(:id => params[:node_id])
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

  def destroy
    @resource = Resource.find(params[:id])
    node_id = @resource.node_id
    if @resource.destroy
      flash[:notice] = "Resource removed"
    else
      flash[:error] = "Please try again"
    end
    redirect_to node_path(:id => node_id)
  end
end

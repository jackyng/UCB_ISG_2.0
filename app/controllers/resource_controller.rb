class ResourceController < ApplicationController
  def create
    @node = Node.find(params[:node_id])
    @resource = @node.resources.new(:name => params[:name], :url => params[:url], :count => 0)

    if params[:name].nil? or params[:url].nil?
      render :create
      return
    end

    if @resource.save
      flash[:notice] = "Resource created"
      flash[:error] = ""
      redirect_to node_path(:id => params[:node_id])
    else
      flash[:error] = "Please check your name and url {#{params[:name]}} {#{params[:url]}}"
      flash[:notice] = ""
    end
    # redirect_to root_url
  end

  def destroy
    @resource = Resource.find(params[:id])
    if @resource.destroy
      flash[:notice] = "Resource removed"
    else
      flash[:error] = "Please try again"
    end
    redirect_to root_url
  end
end

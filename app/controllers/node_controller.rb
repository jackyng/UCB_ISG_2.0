class NodeController < ApplicationController
  def index
    @nodes = Node.all
  end

  def create
    @node = Node.create(:name => params[:name])
    redirect_to :controller => :parenthood, :action => :add, :node_id => @node.id, :parent_id => params[:parent_id]
  end

  def destroy
    @node = Node.find(params[:id])
    @node.destroy
    flash[:notice] = "Removed node"
  end

  def add
    # Add child and connect parenthood
  end

  def remove
  end

  def add_resource
  end

  def remove_resource
  end
end

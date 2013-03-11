class NodeController < ApplicationController
  def index
    @node = Node.find(1)
    @children = @node.children
    @ancestors = @node.ancestors
  end

  def create
    @node = Node.create(:name => params[:name])
  end

  def destroy
    @node = Node.find(params[:node_id])
    if @node.name == "ISG_root"
      flash[:error] = "Can't remove the default root node"
    elsif @node.has_children?
      flash[:error] = "Node has children, can't remove!"
    else
      @node.destroy
      flash[:notice] = "Removed node"
    end
    redirect_to root_url
  end

  def add_child
    new_child = Node.new(:name => params[:name])
    new_child.parent = Node.find(params[:parent])
    new_child.save

    redirect_to root_url
  end

  def add_resource
  end

  def remove_resource
  end
end

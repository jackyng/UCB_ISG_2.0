class NodeController < ApplicationController
  def index
    id = if params[:id]
      params[:id]
    else
      1
    end
    @node = Node.find(id)
    @children = @node.children
    @ancestors = @node.ancestors
  end

  def create
    @node = Node.create(:name => params[:name])
  end

  def destroy
    @node = Node.find(params[:node_id])
    parent_id = @node.parent.id
    if @node.name == "ISG_root"
      flash[:error] = "Can't remove the default root node"
    elsif @node.has_children?
      flash[:error] = "Node has children, can't remove!"
    else
      @node.destroy
      flash[:notice] = "Removed node"
    end
    redirect_to node_path(:id => parent_id)
  end

  def add_child
    new_child = Node.new(:name => params[:name])
    new_child.parent = Node.find(params[:parent])
    if new_child.save
      flash[:notice] = "Created child node '#{new_child.name}' to parent node '#{new_child.parent.name}'"
      redirect_to node_path(:id => new_child.parent)
    end
  end

  def add_resource
  end

  def remove_resource
  end
end
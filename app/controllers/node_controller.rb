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
    # Data validation
    if params[:name] == Isg2::Application::ROOT_NODE_NAME
      flash[:error] = 'Error: illegal topic name "' + Isg2::Application::ROOT_NODE_NAME + '".'
      redirect_to node_path(:id => params[:parent])
      return
    end

    @node = Node.create(:name => params[:name])
  end

  def destroy
    @node = Node.find(params[:node_id])
    parent_id = @node.parent.id
    if @node.name == Isg2::Application::ROOT_NODE_NAME
      flash[:error] = "Error: can't remove the root topic."
    elsif @node.has_children?
      flash[:error] = "Error: can't remove a topic with subtopics."
    else
      @node.destroy
      flash[:notice] = "Successfully removed topic."
    end
    redirect_to node_path(:id => parent_id)
  end

  def add_child
    # Data validation
    if params[:name] == Isg2::Application::ROOT_NODE_NAME
      flash[:error] = 'Error: illegal topic name "' + Isg2::Application::ROOT_NODE_NAME + '".'
      redirect_to node_path(:id => params[:parent])
      return
    end

    new_child = Node.new(:name => params[:name])
    new_child.parent = Node.find(params[:parent])
    if new_child.save
      flash[:notice] = "Successfully created subtopic '#{new_child.name}' under '#{new_child.parent.name}'"
      redirect_to node_path(:id => new_child.parent)
    end
  end

  def add_resource
  end

  def remove_resource
  end
end

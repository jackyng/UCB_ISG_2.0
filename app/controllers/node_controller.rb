class NodeController < ApplicationController
  def index
    id = if params[:id]
      params[:id]
    else
      root = Node.find_by_name(Isg2::Application::ROOT_NODE_NAME)
      if root.nil?
        root = Node.create(:name => Isg2::Application::ROOT_NODE_NAME)
      end
      root.id
    end
    @node = Node.find(id)
    @children = @node.children
    @ancestors = @node.ancestors
    @resources = @node.resources
  end

  def create
    # Data validation
    # If same name as root node, prevent creation
    if params[:name] == Isg2::Application::ROOT_NODE_NAME
      flash[:error] = 'Error: illegal topic name "' + Isg2::Application::ROOT_NODE_NAME + '".'
      redirect_to node_path(:id => params[:parent])
      return
    end
    # If name would be the same as one of its siblings, prevent creation
    parent_node = Node.find(params[:parent])
    potential_siblings = parent_node.children
    if potential_siblings.exists?(:name => params[:name])
      flash[:error] = 'Error: illegal topic name "' + params[:name] + '". Name already belongs to a node at the same level.'
      redirect_to node_path(:id => params[:parent])
      return
    end

    @node = Node.create(:name => params[:name])
  end

  def destroy
    @node = Node.find(params[:node_id])
    parent_id = @node.parent.id unless @node.parent.nil?
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
    # If same name as root node, prevent creation
    if params[:name] == Isg2::Application::ROOT_NODE_NAME
      flash[:error] = 'Error: illegal topic name "' + Isg2::Application::ROOT_NODE_NAME + '".'
      return
    end
    # If name would be the same as one of its siblings, prevent creation
    parent_node = Node.find(params[:parent])
    potential_siblings = parent_node.children
    if potential_siblings.exists?(:name => params[:name])
      flash[:error] = 'Error: illegal topic name "' + params[:name] + '". Name already belongs to a node at the same level.'
      return
    end

    new_child = Node.new(:name => params[:name])
    new_child.parent = Node.find(params[:parent])
    if new_child.save
      flash[:notice] = "Successfully created subtopic '#{new_child.name}' under '#{new_child.parent.name}'"
      redirect_to node_path(:id => new_child.parent)
    end
  end
end

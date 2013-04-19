class NodeController < ApplicationController
  respond_to :html, :json
  # This will allow the user to view the index page without authentication
  # but will process CAS authentication data if the user already
  # has an SSO session open.
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => :index

  # This requires the user to be authenticated for viewing allother pages.
  before_filter CASClient::Frameworks::Rails::Filter, :except => :index

  before_filter :setup_session_info
  before_filter :check_admin_privilege, :only => [:create, :destroy]

  def index
    id = if params[:id]
      params[:id]
    else
      @root_node = Node.find_by_name(Isg2::Application::ROOT_NODE_NAME)
      @root_node ||= Node.create(name: Isg2::Application::ROOT_NODE_NAME, description: Isg2::Application::ROOT_NODE_DESCRIPTION)
      @root_node.id
    end
    @root_node ||= Node.find_by_name(Isg2::Application::ROOT_NODE_NAME)
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
      return
    end
    # If name would be the same as one of its siblings, prevent creation
    parent_node = Node.find(params[:parent])
    potential_siblings = parent_node.children
    if potential_siblings.exists?(:name => params[:name])
      flash[:error] = 'Error: illegal topic name "' + params[:name] + '". Name already belongs to a node at the same level.'
      return
    end

    new_child = Node.new(name: params[:name], description: params[:description])
    new_child.parent = Node.find(params[:parent])
    if new_child.save
      flash[:notice] = "Successfully created subtopic '#{new_child.name}' under '#{new_child.parent.name}'"
      redirect_to :root
    end
  end

  def edit
    @node = Node.find(params[:node_id])
    if @node.update_attributes(name: params[:name], description: params[:description])
      redirect_to :root
    end
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
    redirect_to :root
  end
end

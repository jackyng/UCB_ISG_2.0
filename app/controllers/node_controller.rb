class NodeController < ApplicationController
  respond_to :html, :json
  # This will allow the user to view the index page without authentication
  # but will process CAS authentication data if the user already
  # has an SSO session open.
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => :index

  # This requires the user to be authenticated for viewing allother pages.
  before_filter CASClient::Frameworks::Rails::Filter, :except => [:index, :graphview, :getData]

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
    @anncs = Announcement.all()
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

  def getData
    root = Node.find_by_name(Isg2::Application::ROOT_NODE_NAME)
    data = {}
    data[:nodes] = getNodes(root)
    data[:edges] = getEdges(root)
    respond_to do |format|
      format.json {render :json => data}
    end
  end

  def import
    content = params[:json_content]
    errorMessage = ""
    noticeMessage = ""
    begin
      unless content.nil?
        json_content = JSON.parse(content)
        json_content.each do |object| 
          if object['node']
            newNode = object['node']
            tuple = createNewNode(newNode['name'], newNode['description'], params[:node_id], errorMessage, noticeMessage)
            node_id = tuple[0]
            errorMessage = tuple[1]
            noticeMessage = tuple[2]
            unless node_id.nil?
              tuple = addChildren(newNode['children'], node_id, errorMessage, noticeMessage)
              errorMessage = tuple[0]
              noticeMessage = tuple[1]
            end
          elsif object['resource']
            newResource = object['resource']
            tuple = createNewResource(newResource['name'], newResource['url'], params[:node_id], errorMessage, noticeMessage)
            errorMessage = tuple[0]
            noticeMessage = tuple[1]
          end
        end
        unless errorMessage.blank?
          flash[:error] = errorMessage.html_safe
        end
        unless noticeMessage.blank?
          flash[:notice] = noticeMessage.html_safe
        end
        redirect_to :root
      end
    rescue JSON::ParserError
      flash[:error] = "Error: The json is not well-format"
    end
  end

  private
  def addChildren(children, parent_id, errorMessage, noticeMessage)
    if children.empty?
      return
    else
      children.each do |object|
        if object['node']
          newNode = object['node']
          tuple = createNewNode(newNode['name'], newNode['description'], parent_id, errorMessage, noticeMessage)
          node_id = tuple[0]
          errorMessage = tuple[1]
          noticeMessage = tuple[2]
          unless node_id.nil?
            tuple = addChildren(newNode['children'], node_id, errorMessage, noticeMessage)
            unless tuple.nil?
              errorMessage = tuple[0]
              noticeMessage = tuple[1]
            end
          end
        elsif object['resource']
          newResource = object['resource']
          tuple = createNewResource(newResource['name'], newResource['url'], parent_id, errorMessage, noticeMessage)
          errorMessage = tuple[0]
          noticeMessage = tuple[1]
        end
      end
      return [errorMessage, noticeMessage]
    end
  end

  def createNewNode(name, description, parent_id, errorMessage, noticeMessage)
    # Data validation
    # If same name as root node, prevent creation
    if name == Isg2::Application::ROOT_NODE_NAME
      errorMessage += "Error: illegal topic name '" + Isg2::Application::ROOT_NODE_NAME + "'." + "</br>"
      return [nil, errorMessage, noticeMessage]
    end
    # If name would be the same as one of its siblings, prevent creation
    parent_node = Node.find(parent_id)
    parent_name = parent_node.name
    potential_siblings = parent_node.children
    if potential_siblings.exists?(:name => name)
      errorMessage += 'Error: illegal topic name "' + name + '". Name already belongs to a node at the same level.' + "</br>"
      return [nil, errorMessage, noticeMessage]
    end

    new_child = Node.new(name: name, description: description)
    new_child.parent = Node.find(parent_id)
    if new_child.save
      noticeMessage += "Successfully created subtopic '"+  name + "' under '" + parent_name + "'" + "</br>"
      return [new_child.id, errorMessage, noticeMessage]
    end
  end

  def createNewResource(name, url, node_id, errorMessage, noticeMessage)
    node = Node.find(node_id)
    parent_name = node.name
    resource = node.resources.new(:name => name, :url => url)
    if resource.save
      noticeMessage += "Successfully created resource '" + name + "' under '" + parent_name + "'" + "</br>"
    else
      if not Resource.find_by_name(name).blank?
        errorMessage += "Another resource with same name '" + name + "' already created!" + "</br>"
      elsif not Resource.find_by_url(url).blank?
        errorMessage += "Another resource with same url '" + url + "' already created!" + "</br>"
      else
        errorMessage += "Please check your name '" + name + "' and/or url '" + url  + "'" + "</br>"
      end
    end
    return [errorMessage, noticeMessage]
  end

  def getNodes(node) 
    clr = {
      :root => "red",
      :node => "#b2b19d",
      :resource => "#922E00"
    }
    data = {}
    if node == Node.find_by_name(Isg2::Application::ROOT_NODE_NAME)
      data[node.name] = {:color => clr[:root], :shape => "dot", :alpha => 1}
    elsif node.parent == Node.find_by_name(Isg2::Application::ROOT_NODE_NAME)
      data[node.name] = {:color => clr[:node], :shape => "dot", :alpha => 1}
    else
      data[node.name] = {:color => clr[:node], :shape => "dot", :alpha => 0}
    end
    node.children.each do |child|
      data = data.merge(getNodes(child))
    end
    return data
  end

  def getEdges(node)
    data = {}
    children = {}
    node.children.each do |child|
      children = children.merge({child.name => {}})
      data = data.merge(getEdges(child))
    end
    data[node.name] = children
    return data
  end
end

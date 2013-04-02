module NodeHelper
	def display_segment(node, isAdmin)
    if (node.depth > 0)     
        html = "<li class=\"closed\">"
    else 
        html = "<li class=\"opened\">"
    end
    html << "<span><i class=\"icon-book\"></i>#{h(node.name)}</span>"
    add_child_path = node_create_path(:parent => node)
    remove_child_path = node_destroy_path(:node_id => node.id)
    add_resource_path = resource_create_path(:node_id => node.id)
    if (isAdmin) 
        html << "<span><a href=\"#{h(add_child_path)}\" class=\"tree_func\" data-method=\"get\">Add child</a></span>"
        if (node.depth > 0)
            html << "<span><a href=\"#{h(remove_child_path)}\" class=\"tree_func\" data-method=\"get\">Remove child</a></span>"
        end
        html << "<span><a href=\"#{h(add_resource_path)}\" class=\"tree_func\" data-method=\"get\">Add resource </a></span>"
    end
    html << "<ul>"
    node.children.each{|child_node|
      html << display_segment(child_node, isAdmin)
    }
    node.resources.each{|resource|
    	html << "<li>"
        html << "<a href=\"#{h(resource.url)}\" class=\"iframe\"><i class=\"icon-file\"></i>#{h(resource.name)}</a>"
    	if (isAdmin)
            remove_resource_path = resource_destroy_path(:id => resource.id)
            html << "<span><a href=\"#{h(remove_resource_path)}\" class=\"tree_func\" data-method=\"get\">Remove resource</a></span>"
        end
        html << "</li>"
    }
    html << "</ul></li>"
    html.html_safe
  end
end

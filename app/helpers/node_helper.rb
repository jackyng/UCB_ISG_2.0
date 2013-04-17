module NodeHelper
	def display_segment(node, isAdmin)
    node_id = "node_" + node.id.to_s()
    if (node.depth > 0)     
        html = "<li class=\"closed\">"
        html << "<span draggable=\"true\" id=\"#{h(node_id)}\" class=\"tree_nodes\"><i class=\"icon-book\"></i>#{h(node.name)}</span>"
    else 
        unless isAdmin
            html = "<li class=\"opened\">"
        else
            html = "<li id=\"isAdmin\" class=\"opened\">"
        end
        html << "<span id=\"#{h(node_id)}\" class=\"root_node\"><i class=\"icon-book\"></i>#{h(node.name)}</span>"
    end
    html << "<ul>"
    node.children.each{|child_node|
      html << display_segment(child_node, isAdmin)
    }
    node.resources.each{|resource|
        resource_id = "resource_" + resource.id.to_s()
    	html << "<li>"
        html << "<a id=\"#{h(resource_id)}\" href=\"#{h(resource.url)}\" class=\"resources iframe\"><i class=\"icon-file\"></i>#{h(resource.name)}</a>"
        html << "</li>"
    }
    html << "</ul></li>"
    html.html_safe
  end
end

module NodeHelper
	def display_segment(node)
    html = "<li class=\"closed\">"
    html << "<span><i class=\"icon-book\"></i>#{h(node.name)} </span>"
    html << "<ul id=\"children_of_#{h(node.id)}\">"
    node.children.each{|child_node|
      html << display_segment(child_node)
    }
    node.resources.each{|resource|
    	html << "<li>"
    	html << "<a onclick=\"showResource(#h{resource.url})\"><i class=\"icon-file\"></i>#{h(resource.name)}</a>"
    	html << "</li>"
    }
    html << "</ul></li>"
    html.html_safe
  end
end

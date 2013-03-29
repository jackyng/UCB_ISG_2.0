module NodeHelper
	def display_segment(node)
    if (node.depth > 0)     
        html = "<li class=\"closed\">"
    else 
        html = "<li class=\"opened\">"
    end
    html << "<span><i class=\"icon-book\"></i>#{h(node.name)} </span>"
    html << "<ul>"
    node.children.each{|child_node|
      html << display_segment(child_node)
    }
    node.resources.each{|resource|
    	html << "<li>"
        html << "<button onclick=\"displayResource('#{h(resource.url)}')\" class=\"resource\" type=\"button\"><i class=\"icon-file\"></i>#{h(resource.name)}</button>"
    	html << "</li>"
    }
    html << "</ul></li>"
    html.html_safe
  end
end

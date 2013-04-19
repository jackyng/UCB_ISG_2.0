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

  def find_node_param(node_id, key)
    @node = Node.find(node_id)
    if (key == 'name')
        return @node.name
    else
        return @node.description
    end
  end

  def display_recent_annc()
    html_code = ""
    notices = Announcement.last(5).reverse
    if notices[0]
        html_code << "<li>"
        html_code << "<a href=\"#{h(announcement_notice_path(id: notices[0].id))}\">#{h(notices[0].title)}</a>"
        html_code << "</li>"
    end
    if notices[1]
        html_code << "<li>"
        html_code << "<a href=\"#{h(announcement_notice_path(id: notices[1].id))}\">#{h(notices[1].title)}</a>"
        html_code << "</li>"
    end
    if notices[2]
        html_code << "<li>"
        html_code << "<a href=\"#{h(announcement_notice_path(id: notices[2].id))}\">#{h(notices[2].title)}</a>"
        html_code << "</li>"
    end
    if notices[3]
        html_code << "<li>"
        html_code << "<a href=\"#{h(announcement_notice_path(id: notices[3].id))}\">#{h(notices[3].title)}</a>"
        html_code << "</li>"
    end
    if notices[4]
        html_code << "<li>"
        html_code << "<a href=\"#{h(announcement_notice_path(id: notices[4].id))}\">#{h(notices[4].title)}</a>"
        html_code << "</li>"
    end
    html_code.html_safe
  end
end

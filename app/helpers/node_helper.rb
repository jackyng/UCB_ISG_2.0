module NodeHelper
	def display_segment(node, isAdmin)
    node_id = "node_" + node.id.to_s()
    if (node.depth > 0)     
        html = "<li class=\"closed\">"
        html << "<span draggable=\"true\" id=\"#{h(node_id)}\" class=\"tree_nodes\" rel=\"tooltip\" data-original-title=\"#{h(node.description)}\"><i class=\"icon-book\"></i>#{h(node.name)}</span>"
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
        html << "<i class=\"icon-file\"></i>"
        html << link_to(
            resource.name,
            resource_open_path(resource.id),
            id: resource_id,
            class: "resources iframe",
            rel: "tooltip",
            title: @admin ? h("#{resource.description} (#{resource.count} views)") : h(resource.description)
        )
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
    showing_announcements = Announcement.where(shown_on_homepage: true).order("created_at desc")
    unless showing_announcements.blank?
        html_code = "<div class=\"alert alert-info\"id=\"announcement_feed\"><ul>"
        showing_announcements.each do |notice|
            html_code << "<li>"
            html_code << "<a href=\"#{h(announcement_notice_path(id: notice.id))}\">#{h(notice.title)}</a>"
            html_code << "</li>"
        end
        html_code << "</ul></div>"
        html_code.html_safe
    end
  end

  def display_annc_tab()
    showing_announcements = Announcement.where(shown_on_homepage: true).order("created_at desc")
    html_code = "<table class=\"table table-stripped table-hover table-condensed\"><thead><tr><th>Submitted Date</th><th>Title</th></tr></thead>"
    unless showing_announcements.blank?
        html_code << "<tbody>"
        showing_announcements.each do |notice|
            html_code << "<tr><td>#{h(notice.created_at)}</td>"
            html_code << "<td>#{h(notice.title)}</td>"
            html_code << "<td><button class=\"btn btn-small btn-info\" onclick=\"displayAnnc(#{h(notice.id)})\" type=\"button\">Content</button></td></tr>"
        end
        html_code << "</tbody></table>"
        html_code.html_safe
    end
  end

end

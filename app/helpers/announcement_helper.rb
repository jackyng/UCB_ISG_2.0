module AnnouncementHelper
  def find_announcement_param(notice_id, key)
    @notice = Announcement.find(notice_id)
    if (key == 'title')
        return @notice.title
    else
        return @notice.description
    end
  end

  def displayAnncContent(annc_id)
        current_annc = Announcement.find_by_id(annc_id)
        content = "<h2>#{h(current_annc.title)}</h2>"
        content << "<h5>Description:</h5>"
        content << "#{h(current_annc.description)}<br>"
        content.html_safe
  end

  def backanncbutton()
        back = "<a class=\"btn btn-small btn-primary\" href=\"#{h(root_path)}\" data-method=\"get\">Back</a>"
        back.html_safe
  end
end
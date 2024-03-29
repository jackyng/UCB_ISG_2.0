module ApplicationHelper
	# Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "UCB ISG"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def isAdmin(admin_id)
  	admin = Admin.find(admin_id)
  	if admin.nil?
      return false
    else
      return true
    end
  end

  def backButton()
    back = "<a class=\"btn btn-primary\" href=\"#{h(root_path)}\" data-method=\"get\">Back</a>"
    back.html_safe
  end
end

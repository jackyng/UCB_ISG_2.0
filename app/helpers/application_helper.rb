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

  def isAdmin(user_id)
  	user = User.find(user_id)
  	return user.isAdmin
  end
end

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

  def ldap_lookup(calnet_id)
    unless calnet_id.nil?
      ldap = Net::LDAP.new(
        host: 'ldap.berkeley.edu',
        port: 389
      )
      if ldap.bind
        ldap.search(
          base:          "ou=people,dc=berkeley,dc=edu",
          filter:        Net::LDAP::Filter.eq( "uid", calnet_id.to_s ),
          attributes:    %w[ displayName ],
          return_result: true
        ).first.displayName.first
      else
        flash[:error] = "Can't connect to LDAP to get user's name"
      end
    end
  end
end

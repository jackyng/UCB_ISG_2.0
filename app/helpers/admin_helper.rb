module AdminHelper
  def displayAddAdminLink(user)
    html_code = ""
    if user.email
      html_code << link_to("Add Admin", admin_create_path(fullname: user.fullname, email: user.email, calnetID: user.calnetID), :method => :post, :title => "This adds the admin")
    else
      html_code << "<form id=\"admin_index_form\" class=\"form-inline\" action=\"#{h(admin_create_path)}\" method=\"get\">"
      html_code << "<input id=\"email\" name=\"email\" type=\"email\" class=\"input-medium\" placeholder=\"Email required!\">"
      html_code << "<input id=\"fullname\" name=\"fullname\" type=\"hidden\" value=\"#{h(user.fullname)}\">"
      html_code << "<input id=\"calnetID\" name=\"calnetID\" type=\"hidden\" value=\"#{h(user.calnetID)}\">"
      html_code << "&nbsp;&nbsp;<button type=\"submit\" class=\"btn btn-small btn-primary btn-info\">Save email & add as Admin</button>"
      html_code << "</form>"
    end
    html_code.html_safe
  end

  def displayAddAdminLinkFromLDAP(ldap_entry)
    fullname = ldap_entry.displayName.first
    calnetID = ldap_entry.uid.first
    email = ldap_entry.respond_to?(:mail) ? ldap_entry.mail.first : nil
    html_code = ""
    if Admin.find_by_calnetID(calnetID)
      html_code << "Already an admin"
    elsif email
      html_code << link_to("Add Admin", admin_create_path(fullname: fullname, email: email, calnetID: calnetID), :method => :post, :title => "This adds the admin")
    else
      html_code << "<form class=\"form-inline\" action=\"#{h(admin_create_path)}\" method=\"get\">"
      html_code << "<input id=\"email\" name=\"email\" type=\"email\" class=\"input-medium\" placeholder=\"Email required!\">"
      html_code << "<input id=\"fullname\" name=\"fullname\" type=\"hidden\" value=\"#{h(fullname)}\">"
      html_code << "<input id=\"calnetID\" name=\"calnetID\" type=\"hidden\" value=\"#{h(calnetID)}\">"
      html_code << "&nbsp;&nbsp;<button type=\"submit\" class=\"btn btn-small btn-primary disabled\">Save email & add as Admin</button>"
      html_code << "</form>"
    end
    html_code.html_safe
  end

end

module AdminHelper
  def displayAddAdminLink(user)
    html_code = ""
    if user.email
      html_code << link_to("Add Admin", admin_create_path(fullname: user.fullname, email: user.email, calnetID: user.calnetID), :method => :post, :title => "This adds the admin")
    else
      html_code << "<form class=\"form-inline\" action=\"#{h(admin_create_path)}\" method=\"get\">"
      html_code << "<input id=\"email\" name=\"email\" type=\"text\" class=\"input-small\" placeholder=\"Email required!\">"
      html_code << "<input id=\"fullname\" name=\"fullname\" type=\"hidden\" value=\"#{h(user.fullname)}\">"
      html_code << "<input id=\"calnetID\" name=\"calnetID\" type=\"hidden\" value=\"#{h(user.calnetID)}\">"
      html_code << "<button type=\"submit\" class=\"btn btn-primary\">Save email & add as Admin</button>"
      html_code << "</form>"
    end
    html_code.html_safe
  end
end

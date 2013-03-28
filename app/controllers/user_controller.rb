class UserController < ApplicationController
  def login
    @login_url = CASClient::Frameworks::Rails::Filter.login_url(self)
    @uid = session[:cas_user]
    @fullname ||= name_for_uid() unless @uid.nil?
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
end

class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  before_filter :check_admin_privilege, :only => :toggle_admin

  def toggle_admin
    # TODO
  	@c = User.find(params[:user_id])
  	@c.toggle!(:isAdmin)
  	redirect_to user_path
  end

  def index
  	@users = User.all()
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
end

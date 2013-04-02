class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :get_calnet_info

  def toggle_admin
  	@c = User.find(params[:id])
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

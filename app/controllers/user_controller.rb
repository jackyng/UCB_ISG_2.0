class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  before_filter :check_admin_privilege, :only => [:add_admin, :remove_admin]

  def add_admin
    @a_user = User.find(params[:id])
    a_admin = Admin.new(fullname: @a_user.fullname, calnetID: @a_user.calnetID, email: @a_user.email, last_request_time: @a_user.last_request_time)
    @a_user.destroy
    if a_admin.save
      flash[:notice] = "Successfully added the new Admin, '#{a_admin.fullname}'"
    end
    redirect_to user_path
  end

  def remove_admin
  	@r_admin = Admin.find(params[:id])
  	r_user = User.new(fullname: @r_admin.fullname, calnetID: @r_admin.calnetID, email: @r_admin.email, last_request_time: @r_admin.last_request_time)
    @r_admin.destroy
  	if r_user.save
      flash[:notice] = "Successfully removed the Admin, '#{r_user.fullname}'"
    end
    redirect_to user_path
  end

  def index
  	@users = User.all()
    @admins = Admin.all()
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
end

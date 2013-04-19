class AdminController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  before_filter :check_admin_privilege

  def create
    p params
    if params[:calnetID]
      if params[:email].nil?
        flash[:error] = "Need an email to be an admin"
        redirect_to admin_path and return
      end
      @new_admin = Admin.new(calnetID: params[:new_calnetID], email: params[:email], last_request_time: Time.now)
      if @new_admin.save
        u = User.find_by_calnetID(params[:new_calnetID])
        u.destroy unless u.nil?
        flash[:notice] = "Successfully added admin '#{@new_admin.fullname}'"
      else
        flash[:error] = @new_admin.errors.values.join(". ")
      end
    end
    redirect_to admin_path
  end

  def destroy
    if params[:id]
      admin = Admin.find(params[:id])
      User.create(fullname: admin.fullname, calnetID: admin.calnetID, email: admin.email, last_request_time: Time.now)
      admin.destroy
      flash[:notice] = "Successfully removed admin '#{admin.fullname}'"
    end
    redirect_to admin_path
  end

  def index
    @admins = Admin.all()
    @users = User.all()
  end
end

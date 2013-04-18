class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :setup_session_info

  private
  def setup_session_info
    @remote_ip = request.remote_ip
    @login_url = CASClient::Frameworks::Rails::Filter.login_url(self)
    @calnet_id = session[:cas_user]

    unless @calnet_id.nil?
      @admin = Admin.find_by_calnetID(@calnet_id)
      if @admin.nil?
        @user = User.find_by_calnetID(@calnet_id)
        if @user.nil?
          @user = User.create(calnetID: @calnet_id)
        end
      end
    end
  end

  def check_admin_privilege
    setup_session_info if @admin.nil?
    if @admin.nil?
      flash[:error] = "Error: You don't have the privilege to perform this action"
      redirect_to :root
    end
  end
end

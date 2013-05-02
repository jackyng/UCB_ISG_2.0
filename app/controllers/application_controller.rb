class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :setup_session_info
  # before_filter :log_request_time

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

  private
  def setup_session_info
    @remote_ip = request.remote_ip
    @login_url = CASClient::Frameworks::Rails::Filter.login_url(self)
    @calnet_id = session[:cas_user]
    @user_admin = false

    unless @calnet_id.nil?
      @admin = Admin.find_by_calnetID(@calnet_id)
      @user_admin = true
      if @admin.nil?
        @user = User.find_by_calnetID(@calnet_id)
        if @user.nil?
          @user = User.create(calnetID: @calnet_id)
          flash[:error] = @user.errors.map {|k,v| "#{k} error: #{v}"}.join(". ")
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

  # def log_request_time
  #   req = Request.find_by_ip_address(request.remote_ip)
  #   if req.nil?
  #     req = Request.create(ip_address: request.remote_ip)
  #   end

  #   if session[:cas_user]
  #     req.isRegistered = true
  #   end
  #   req.request_time = Time.now
  #   req.save
  # end
end

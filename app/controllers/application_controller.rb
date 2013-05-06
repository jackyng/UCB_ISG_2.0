class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :setup_session_info #, if: lambda { @user.nil? and @admin.nil? }
  before_filter :log_request_time
  before_filter :online_users

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

  private
  def setup_session_info
    @remote_ip = request.remote_ip
    @login_url = CASClient::Frameworks::Rails::Filter.login_url(self)
    @calnet_id = session[:cas_user]
    @user_admin = false
    flash[:errors] = []

    unless @calnet_id.nil?
      @admin = Admin.find_by_calnetID(@calnet_id)
      unless @admin.nil?
        @user_admin = true
      else
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

  def log_request_time
    req = Request.find_by_ip_address(request.remote_ip)
    if req.nil?
      req = Request.create(ip_address: request.remote_ip)
    end

    if session[:cas_user]
      req.isRegistered = true
      setup_session_info if @user.nil? and @admin.nil?
      if @user
        User.find_by_calnetID(session[:cas_user]).update_attributes(last_request_time: Time.now)
      elsif @admin
        Admin.find_by_calnetID(session[:cas_user]).update_attributes(last_request_time: Time.now)
      end
    end
    req.request_time = Time.now
    req.save
  end

  def online_users
    @online_people = Request.count
    @online_registered = Request.find_all_by_isRegistered(true).count
  end
end

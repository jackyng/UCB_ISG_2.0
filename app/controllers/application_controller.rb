class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :name_for_calnet_id

  private
  def get_calnet_info
    unless session[:cas_user].nil?
      @current_user = User.find_or_create_by_calnetID(session[:cas_user])
      @user_fullname = name_for_calnet_id(session[:cas_user])
    end

    @remote_ip = request.remote_ip
    @login_url = CASClient::Frameworks::Rails::Filter.login_url(self)
    @user_admin = @current_user.isAdmin unless @current_user.nil?
  end

  def name_for_calnet_id(cid)
    ldap = Net::LDAP.new(
      host: 'ldap.berkeley.edu',
      port: 389
    )
    if ldap.bind
      ldap.search(
        base:          "ou=people,dc=berkeley,dc=edu",
        filter:        Net::LDAP::Filter.eq( "uid", cid.to_s ),
        attributes:    %w[ displayName ],
        return_result: true
      ).first.displayName.first
    else
      flash[:error] = "Can't connect to LDAP to get user's name"
    end
  end
end

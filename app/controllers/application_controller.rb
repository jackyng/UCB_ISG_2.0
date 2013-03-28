class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :get_calnet_info
  private
  def get_calnet_info
    @login_url = CASClient::Frameworks::Rails::Filter.login_url(self)
    @calnet_id = session[:cas_user]
    @user_fullname ||= name_for_calnet_id() unless @calnet_id.nil?
    @remote_ip = request.remote_ip
  end

  private
  def name_for_calnet_id
    ldap = Net::LDAP.new(
      host: 'ldap.berkeley.edu',
      port: 389
    )
    if ldap.bind
      ldap.search(
        base:         "ou=people,dc=berkeley,dc=edu",
        filter:       Net::LDAP::Filter.eq( "uid", @calnet_id ),
        attributes:   %w[ displayName ],
        return_result:true
      ).first.displayName.first
    else
      flash[:error] = "Can't connect to LDAP"
    end
  end
end

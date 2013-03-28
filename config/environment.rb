# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Isg2::Application.initialize!

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "https://auth.berkeley.edu/cas",
  :login_url    => "https://auth.berkeley.edu/cas/login",
  :logout_url   => "https://auth.berkeley.edu/cas/logout",
  :validate_url => "https://auth.berkeley.edu/cas/serviceValidate",
  :username_session_key => :cas_user,
  :enable_single_sign_out => true
)
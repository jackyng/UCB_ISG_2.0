class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
end

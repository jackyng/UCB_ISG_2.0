require 'spec_helper'

describe UserController do
  context "received success request" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake('181758')
    end

    it "GET /login"

    it "GET /logout" do
      get 'logout'
      response.should be_redirect
      response.redirect_url.should match /https:\/\/auth\.berkeley\.edu\/cas\/logout\?service/
    end
  end

  context "received bad request" do
  end
end
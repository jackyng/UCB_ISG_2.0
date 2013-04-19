require 'spec_helper'

describe AdminController do
  context "received good request:" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake('181758')
    end
  end
end

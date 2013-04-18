require 'spec_helper'

describe ComplaintController do
  before(:each) do
    @root = Node.create(:name => Isg2::Application::ROOT_NODE_NAME)
    @user = User.create(:calnetID => 181758)
    CASClient::Frameworks::Rails::Filter.fake('181758')
  end

  describe "users make good requests:" do
  end

  describe "users make bad requests:" do
  end

  describe "non-users can't make requests:" do
  end
end

require 'spec_helper'

describe ResourceController do
  before(:each) do
    @root = Node.create(name: Isg2::Application::ROOT_NODE_NAME, description: Isg2::Application::ROOT_NODE_DESCRIPTION)
    @user  = User.create(calnetID: 181758)
    @admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
    CASClient::Frameworks::Rails::Filter.fake(@admin.calnetID.to_s)
  end

  context "admins make good requests:" do
    describe "GET 'resource/create' -" do
      it "create a new resource under a topic and redirect to that topic path" do
        get 'create', { :name => "169", :url => "169.edu", :node_id => @root.id }
        flash[:error].should be_blank
        resource = Resource.where(:name => "169", :url => "169.edu")[0]
        resource.should_not be_nil

        @root.resources.should include(resource)
        response.should be_redirect
        response.should redirect_to(node_path(:id => @root.id))
      end
    end

    describe "GET 'resource/destroy' -" do
      it "destroy resource and return to the path of the topic containing it before deletion" do
        get 'create', { :name => "169", :url => "169.edu", :node_id => @root.id }
        resource = Resource.where(:name => "169", :url => "169.edu")[0]

        get 'destroy', :id => resource.id
        @root.resources.should_not include(resource)
        response.should be_redirect
        response.should redirect_to(node_path(:id => @root.id))
      end
    end
  end

  context "admins make bad request:" do
    describe "GET 'resource/create' duplicate resource name -" do
      it "return to the form with error message" do
        get 'create', :name => "", :url => '', :node_id => @root.id
        flash[:error].should match /Please check your name '.*' and\/or url '.*'/
      end
    end
    
    describe "GET 'resource/create' duplicate resource name -" do
      it "return to the form with error message" do
        get 'create', :name => "169", :url => '169.edu', :node_id => @root.id
        get 'create', :name => "169", :url => 'furd169.edu', :node_id => @root.id
        flash[:error].should match /Another resource with same name already created/
      end
    end

    describe "GET 'resource/create' duplicate resource url -" do
      it "return to the form with error message" do
        get 'create', :name => "169", :url => '169.edu', :node_id => @root.id
        get 'create', :name => "furd169", :url => '169.edu', :node_id => @root.id
        flash[:error].should match /Another resource with same url already created/
      end
    end
  end

  context "non-admins can't make requests to ResourceController:" do
    describe "GET 'resource/create' -" do
      it "return to root with error message" do
        CASClient::Frameworks::Rails::Filter.fake(nil, nil)
        get 'create', :name => "169", :url => '169.edu', :node_id => @root.id
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+resource.+create/

        CASClient::Frameworks::Rails::Filter.fake(@user.calnetID.to_s)
        get 'create', :name => "169", :url => '169.edu', :node_id => @root.id
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end
    end

    describe "GET 'resource/destroy -" do
      it "return to root with error message" do
        resource = Resource.create(:name => "169", :url => '169.edu', :node => @root)

        CASClient::Frameworks::Rails::Filter.fake(nil, nil)
        get 'destroy', :id => resource.id
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+resource.+destroy/

        CASClient::Frameworks::Rails::Filter.fake(@user.calnetID.to_s)
        get 'destroy', :id => resource.id
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end
    end
  end
end
require 'spec_helper'

describe ResourceController do
  before(:each) do
    @root = Node.create(:name => Isg2::Application::ROOT_NODE_NAME)
    @user = User.create(:calnetID => 181758, :isAdmin => true)
    CASClient::Frameworks::Rails::Filter.fake('181758')
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
        @user.update_attributes(:isAdmin => false)
        get 'create', :name => "169", :url => '169.edu', :node_id => @root.id
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end
    end

    describe "GET 'resource/destroy -" do
      it "return to root with error message" do
        get 'create', :name => "169", :url => '169.edu', :node_id => @root.id
        @user.update_attributes(:isAdmin => false)

        resource = Resource.where(:name => "169", :url => "169.edu")[0]
        get 'destroy', :id => resource.id
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end
    end
  end
end
require 'spec_helper'

describe ResourceController do
  before(:each) do
    @root = Node.create(name: Isg2::Application::ROOT_NODE_NAME, description: Isg2::Application::ROOT_NODE_DESCRIPTION)
    @user  = User.create(calnetID: 181758)
    @admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
    CASClient::Frameworks::Rails::Filter.fake(@admin.calnetID.to_s)
  end

  context "admins make good requests:" do
    describe "GET 'resource/create'" do
      it "render create form" do
        get 'create', { node_id: @root.id }
        response.should be_success
      end
    end

    describe "POST 'resource/create' with valid arguments" do
      it "create a new resource under a topic and redirect to root path" do
        get 'create', { :name => "169", :url => "169.edu", :node_id => @root.id }
        resource = Resource.where(:name => "169", :url => "169.edu")[0]

        @root.resources.should include(resource)
        response.should be_redirect
        response.should redirect_to :root
        flash[:notice].should == "Resource created"
      end
    end

    describe "GET 'resource/destroy' -" do
      it "destroy resource and return to root path" do
        get 'create', { :name => "169", :url => "169.edu", :node_id => @root.id }
        resource = Resource.where(:name => "169", :url => "169.edu")[0]

        get 'destroy', resource_id: resource.id
        response.should be_redirect
        response.should redirect_to :root
        flash[:notice].should == "Resource '#{resource.name}' removed"
        @root.resources.should_not include(resource)
      end
    end

    describe "GET/POST 'resource/edit'" do
      it "edit the resource and return to root path" do
        resource = @root.resources.create(name: "169furd", url: "169furd.edu")
        get 'edit', { resource_id: resource.id }
        response.should be_success

        post 'edit' , { resource_id: resource.id, name: "169f" }
        response.should be_redirect
        response.should redirect_to :root
        flash[:notice].should == "Resource updated with name '169f' and url '169furd.edu'"
        flash[:error].should be_blank

        post 'edit' , { resource_id: resource.id, url: "169f.edu" }
        response.should be_redirect
        response.should redirect_to :root
        flash[:notice].should == "Resource updated with name '169f' and url '169f.edu'"
        flash[:error].should be_blank

        post 'edit' , { resource_id: resource.id, name: "169", url: "169.edu" }
        response.should be_redirect
        response.should redirect_to :root
        flash[:notice].should == "Resource updated with name '169' and url '169.edu'"
        flash[:error].should be_blank
      end
    end
  end

  context "admins make bad request:" do
    describe "POST 'resource/create' with invalid or nil id" do
      it "return to root path with error message" do
        post 'create'
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should == "Required a parent id to create a subtopic"

        post 'create', { node_id: @root.id+1 }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should == "Invalid parent id '#{@root.id+1}' to create subtopic"
      end
    end

    describe "POST 'resource/create' empty name and/or url -" do
      it "return to the form with error message" do
        [["", "169.edu"], ["169", ""], ["", ""]].each do |name, url|
          post 'create', name: name, url: url, node_id: @root.id
          response.should be_success
          flash[:error].should match /Please check your name '.*' and\/or url '.*'/
        end
      end
    end
    
    describe "GET 'resource/create' duplicate resource name -" do
      it "return to the form with error message" do
        get 'create', name: "169", url: '169.edu', node_id: @root.id
        get 'create', name: "169", url: 'furd169.edu', node_id: @root.id
        flash[:error].should match /Another resource with same name already created/
      end
    end

    describe "GET 'resource/create' duplicate resource url -" do
      it "return to the form with error message" do
        get 'create', name: "169", url: '169.edu', node_id: @root.id
        get 'create', name: "furd169", url: '169.edu', node_id: @root.id
        flash[:error].should match /Another resource with same url already created/
      end
    end

    describe "GET/POST 'resource/edit'" do
      it "return to the form with errors if valid id" do
        resource = @root.resources.create(name: "169furd", url: "169furd.edu")
        [nil, resource.id+1].each do |id|
          post 'edit', { resource_id: id }
          response.should be_redirect
          response.should redirect_to :root
          flash[:error].should == "Need a valid resource id to edit; got '#{id}'"
        end

        post 'edit', { resource_id: resource.id, name: "" }
        response.should be_success
        flash[:notice].should be_blank
        flash[:error].should == "name error: can't be blank"

        post 'edit', { resource_id: resource.id, url: "" }
        response.should be_success
        flash[:notice].should be_blank
        flash[:error].should == "url error: can't be blank"

        post 'edit', { resource_id: resource.id, name: "", url: "" }
        response.should be_success
        flash[:notice].should be_blank
        flash[:error].should include "name error: can't be blank"
        flash[:error].should include "url error: can't be blank"
      end
    end

    describe "GET 'resource/destroy' somehow can't destroy node" do
      it "return to root with error message" do
        resource = @root.resources.create(name: "169", url: '169.edu')
        stubbed_resource = stub(destroy: false, node_id: resource.id+1)
        Resource.stub(:find).and_return(stubbed_resource)
        get 'destroy', { resource_id: resource.id+1 }
        flash[:error].should == "Please try again"
      end
    end
  end

  context "non-admins can't make requests to ResourceController:" do
    describe "GET 'resource/create' -" do
      it "return to root with error message" do
        CASClient::Frameworks::Rails::Filter.fake(nil, nil)
        get 'create', name: "169", url: '169.edu', node_id: @root.id
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+resource.+create/

        CASClient::Frameworks::Rails::Filter.fake(@user.calnetID.to_s)
        get 'create', name: "169", url: '169.edu', node_id: @root.id
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end
    end

    describe "GET 'resource/destroy -" do
      it "return to root with error message" do
        resource = @root.resources.create(name: "169", url: '169.edu')

        CASClient::Frameworks::Rails::Filter.fake(nil, nil)
        get 'destroy', resource_id: resource.id
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+resource.+destroy/

        CASClient::Frameworks::Rails::Filter.fake(@user.calnetID.to_s)
        get 'destroy', resource_id: resource.id
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end
    end
  end
end
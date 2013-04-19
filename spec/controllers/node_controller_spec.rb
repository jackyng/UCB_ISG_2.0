require 'spec_helper'

describe NodeController do
  before(:each) do
    @root = Node.create(name: Isg2::Application::ROOT_NODE_NAME, description: Isg2::Application::ROOT_NODE_DESCRIPTION)
    @user  = User.create(calnetID: 181758)
    @admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
  end

  describe "good request:" do
    context "GET 'node/index' without logging in -" do
      it "returns http success" do
        CASClient::Frameworks::Rails::Filter.fake(nil, nil)
        get 'index'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+gateway=true$/

        # TODO It should eventually redirect back to the index page
        # thus, need to follow redirect twice
        # response.should be_success
      end
    end

    context "admin" do
      before(:each) do
        CASClient::Frameworks::Rails::Filter.fake(@admin.calnetID.to_s)
      end

      it "GET 'node/create' with valid name should returns to the tree view of its parent" do
        get 'create', { parent: @root.id, name: "blah", description: "blahblah" }
        response.should be_redirect
        response.should redirect_to :root
      end

      it "GET 'node/destroy' existing non-root node should returns to the tree view of its parent" do
        n = Node.create(parent: @root, name: "blah", description: "blahblah")

        get 'destroy', { :node_id => n.id }
        response.should be_redirect
        response.should redirect_to :root
      end
    end
  end

  describe "admin makes bad request:" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake(@admin.calnetID.to_s)
    end

    context "GET 'node/create' with root name -" do
      it "render 'node/create' with error message" do
        get 'create', { parent: @root.id, name: Isg2::Application::ROOT_NODE_NAME, description: "root" }
        response.should be_success
        flash[:error].should match /Error: illegal topic name \"#{Isg2::Application::ROOT_NODE_NAME}\"/
      end
    end

    context "GET 'node/create' with same name from sibling node -" do
      it "render 'node/create' with error message" do
        2.times { get 'create', { parent: @root.id, name: "blah", description: "blahblah" } }
        response.should be_success
        flash[:error].should match /Error: illegal topic name.*Name already belongs to a node at the same level/
      end
    end

    context "GET 'node/destroy' to destroy root node -" do
      it "stays on root_url with error message" do
        get 'destroy', { :node_id => @root.id }
        response.should be_redirect
        flash[:error].should match /can't remove the root topic/
      end
    end

    context "GET 'node/destroy' to destroy node with children -" do
      it "stays on root_url with error message" do
        get 'create', { parent: @root.id, name: "1", description: "this is node 1"} # add child

        child = Node.find_by_name("1")
        get 'create', { parent: child.id, name: "1.1", description: "this is 1.1" } # add grandchild
        get 'destroy', { node_id: child.id } # remove child

        response.should be_redirect
        flash[:error].should match /can't remove a topic with subtopics/
      end
    end
  end

  describe "non-admin makes bad request:" do
    context "GET 'node/create' -" do
      it "stays on root_url with error message" do
        CASClient::Frameworks::Rails::Filter.fake(nil, nil)
        get 'create', { parent: @root.id, name: "1", description: "this is node 1"}
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+node.+create/

        CASClient::Frameworks::Rails::Filter.fake(@user.calnetID.to_s)
        get 'create', { parent: @root.id, name: "1", description: "this is node 1"}
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end
    end

    context "GET 'node/destroy' -" do
      it "stays on root_url with error message" do
        child = Node.create(parent: @root, name: "1", description: "this is node 1")

        CASClient::Frameworks::Rails::Filter.fake(nil, nil)
        get 'destroy', { :node_id => child.id }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+node.+destroy/

        CASClient::Frameworks::Rails::Filter.fake(@user.calnetID.to_s)
        get 'destroy', { :node_id => child.id }
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end
    end
  end
end

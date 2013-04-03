require 'spec_helper'

describe NodeController do
  before(:each) do
    @root = Node.create(:name => Isg2::Application::ROOT_NODE_NAME)
    User.create(:calnetID => 181758, :isAdmin => true)
  end

  describe "success request" do
    context "GET 'node/index' without logging in" do
      it "returns http success" do
        get 'index'
        response.should be_redirect
        gateway_url = "https://auth.berkeley.edu/cas/login?service=http%3A%2F%2Ftest.host%2F&gateway=true"
        response.should redirect_to gateway_url

        # TODO It should eventually redirect back to the index page
        # thus, need to follow redirect twice
        # response.should be_success
      end
    end

    context "admin logged in" do
      before(:each) do
        CASClient::Frameworks::Rails::Filter.fake('181758')
      end

      it "GET 'node/create' with valid name should returns to the tree view of its parent" do
        get 'create', { :parent => @root.id, :name => "blah" }
        response.should be_redirect
        response.should redirect_to :root
      end

      it "GET 'node/destroy' existing non-root node should returns to the tree view of its parent" do
        n = Node.new(:name => "blah")
        n.parent = @root
        n.save

        get 'destroy', { :node_id => n.id }
        response.should be_redirect
        response.should redirect_to :root
      end
    end
  end

  describe "admin makes bad request" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake('181758')
    end

    context "GET 'node/create' with root name" do
      it "render 'node/create' with error message" do
        get 'create', { :parent => @root.id, :name => Isg2::Application::ROOT_NODE_NAME }
        response.should be_success
        flash[:error].should match /Error: illegal topic name \"#{Isg2::Application::ROOT_NODE_NAME}\"/
      end
    end

    context "GET 'node/create' with same name from sibling node" do
      it "render 'node/create' with error message" do
        2.times { get 'create', { :parent => @root.id, :name => "blah" } }
        response.should be_success
        flash[:error].should match /Error: illegal topic name.*Name already belongs to a node at the same level/
      end
    end

    context "GET 'node/destroy' to destroy root node" do
      it "stays on node_path with error message" do
        get 'destroy', { :node_id => @root.id }
        response.should be_redirect
        flash[:error].should match /can't remove the root topic/
      end
    end

    context "GET 'node/destroy' to destroy node with children" do
      it "stays on node_path with error message" do
        get 'create', { :parent => @root.id, :name => "1" } # add child

        child = Node.find_by_name("1")
        get 'create', { :parent => child.id, :name => "1.1" } # add grandchild
        get 'destroy', { :node_id => child.id } # remove child

        response.should be_redirect
        flash[:error].should match /can't remove a topic with subtopics/
      end
    end
  end

  describe "non-admin makes bad request:" do
    context "non-admin tries to add child" do
      it "render root_url with error message"
    end
  end
end
require 'spec_helper'

describe NodeController do
  before(:each) do
    @root = Node.create(:name => Isg2::Application::ROOT_NODE_NAME)
  end

  context "success request" do
    describe "GET 'node/index'" do
      it "returns http success" do
        get 'index'
        response.should be_success
      end
    end

    describe "GET 'node/create' with valid name" do
      it "returns to the tree view of its parent" do
        get 'create', { :parent => @root.id, :name => "blah" }
        response.should be_redirect
        response.should redirect_to(node_path(:id => @root.id))
      end
    end

    describe "GET 'node/destroy' existing non-root node" do
      it "returns to the tree view of its parent" do
        n = Node.new(:name => "blah")
        n.parent = @root
        n.save

        get 'destroy', { :node_id => n.id }
        response.should be_redirect
        response.should redirect_to(node_path(:id => @root.id))
      end
    end
  end

  context "bad request" do
    describe "GET 'node/add_child' with root name" do
      it "render 'node/add_child' with error message" do
        get 'add_child', { :parent => @root.id, :name => Isg2::Application::ROOT_NODE_NAME }
        response.should be_success
        flash[:error].should match /Error: illegal topic name \"#{Isg2::Application::ROOT_NODE_NAME}\"/
      end
    end

    describe "GET 'node/add_child' with same name from sibling node" do
      it "render 'node/add_child' with error message" do
        2.times { get 'add_child', { :parent => @root.id, :name => "blah" } }
        response.should be_success
        flash[:error].should match /Error: illegal topic name.*Name already belongs to a node at the same level/
      end
    end

    describe "GET 'node/destroy' to destroy root node" do
      it "stays on node_path with error message" do
        get 'destroy', { :node_id => @root.id }
        response.should be_redirect
        flash[:error].should match /can't remove the root topic/
      end
    end

    describe "GET 'node/destroy' to destroy node with children" do
      it "stays on node_path with error message" do
        get 'add_child', { :parent => @root.id, :name => "1" } # add child

        child = Node.find_by_name("1")
        get 'add_child', { :parent => child.id, :name => "1.1" } # add grandchild
        get 'destroy', { :node_id => child.id } # remove child

        response.should be_redirect
        flash[:error].should match /can't remove a topic with subtopics/
      end
    end
  end
end

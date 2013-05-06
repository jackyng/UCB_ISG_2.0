require 'spec_helper'

describe AnnouncementController do
  before(:each) do
    @root = Node.create(name: Isg2::Application::ROOT_NODE_NAME, description: Isg2::Application::ROOT_NODE_DESCRIPTION)
    @user = User.create(calnetID: 181758)
    @admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
    @announcement = @admin.announcements.create(
      title: "Wifi problem?",
      description: "Please restart your device and try connecting again"
    )
  end

  describe "admin" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake(@admin.calnetID.to_s)
    end

    context "makes good requests:" do
      it "get index" do
        get 'index'
        response.should be_success
      end

      it "get notice" do
        get 'notice', { id: @announcement.id }
        response.should be_success
      end

      it "get/post create" do
        get 'create'
        response.should be_success

        post 'create', { title: "title", description: "description" }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:notice].should == "Successfully submitted announcement 'title'."
        Announcement.where(title: "title", description: "description").should have(1).item
      end

      it "get/post edit" do
        get 'edit', { id: @announcement.id }
        response.should be_success

        post 'edit', { id: @announcement.id, title: "Got wifi?", description: "Too bad" }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:notice].should == "Successfully updated announcement 'Got wifi?'."
        Announcement.where(title: @announcement.title, description: @announcement.description).should have(0).item
        Announcement.where(title: "Got wifi?", description: "Too bad").should have(1).item
      end

      it "delete destroy" do
        delete 'destroy', { id: @announcement.id }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:notice].should == "Successfully removed announcement '#{@announcement.title}'"
        Announcement.find_by_title(@announcement.title).should be_nil
      end

      it "post toggle_show" do
        post 'toggle_show', { id: @announcement.id }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:notice].should == "Announcement '#{@announcement.title}' won't be shown on homepage"
        Announcement.find(@announcement.id).shown_on_homepage.should == false

        post 'toggle_show', { id: @announcement.id }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:notice].should == "Announcement '#{@announcement.title}' will be shown on homepage"
        Announcement.find(@announcement.id).shown_on_homepage.should == true
      end
    end

    context "makes bad requests:" do
      it "get notice" do
        get 'notice', { id: @announcement.id+1 }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:errors].should include "Could not find announcement with id '#{@announcement.id+1}'"
      end

      it "get/post create" do
        post 'create'
        response.should be_success
        flash[:errors].should include "title error: can't be blank."
        flash[:errors].should include "description error: can't be blank."

        post 'create', { description: "Too bad" }
        response.should be_success
        flash[:errors].should include "title error: can't be blank."

        post 'create', { title: "Problem?" }
        response.should be_success
        flash[:errors].should include "description error: can't be blank."
      end

      it "get/post edit" do
        # invalid id
        get 'edit', { id: @announcement.id+1 }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:errors].should include "Could not find announcement with id '#{@announcement.id+1}'"

        post 'edit', { id: @announcement.id+1, title: "Problem?", description: "too bad" }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:errors].should include "Could not find announcement with id '#{@announcement.id+1}'"

        # missing required title and/or description
        post 'edit', { id: @announcement.id }
        response.should be_success
        flash[:errors].should include "title error: can't be blank."
        flash[:errors].should include "description error: can't be blank."

        post 'edit', { id: @announcement.id, description: "too bad" }
        response.should be_success
        flash[:errors].should include "title error: can't be blank."

        post 'edit', { id: @announcement.id, title: "Problem?" }
        response.should be_success
        flash[:errors].should include "description error: can't be blank."
      end

      it "delete destroy" do
        # invalid id
        delete 'destroy', { id: @announcement.id+1 }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:errors].should include "Could not find announcement with id '#{@announcement.id+1}'"

        # somehow can't delete
        stubbed_announcement = stub(destroy: false, title: "title")
        Announcement.stub(:find).and_return(stubbed_announcement)
        delete 'destroy', { id: @announcement.id }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:errors].should include "Can't remove announcement 'title'"
      end

      it "post toggle_show" do
        # invalid id
        post 'toggle_show', { id: @announcement.id+1 }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:errors].should include "Could not find announcement with id '#{@announcement.id+1}'"
      end
    end
  end

  describe "user" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake(@user.calnetID.to_s)
    end

    context "makes good requests:" do
      it "get index" do
        get 'index'
        response.should be_success
      end

      it "get notice" do
        get 'notice', { id: @announcement.id }
        response.should be_success
      end
    end

    context "makes bad requests:" do
      it "get notice" do
        get 'notice', { id: @announcement.id+1 }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:errors].should include "Could not find announcement with id '#{@announcement.id+1}'"
      end

      it "get/post create" do
        get 'create'
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/

        post 'create', { title: "Login problem?", description: "You should email your password to not_a_hacker@hotmail.com" }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end

      it "get/post edit" do
        get 'edit', { id: @announcement.id }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/

        post 'edit', { id: @announcement.id , title: "Login problem?", description: "You should email your password to not_a_hacker@hotmail.com" }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
        announcement = Announcement.find(@announcement.id)
        announcement.title.should == @announcement.title
        announcement.description.should == @announcement.description
      end

      it "delete destroy" do
        delete 'destroy', { id: @announcement.id }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
        Announcement.find(@announcement.id).should_not be_nil
      end

      it "post toggle_show" do
        post 'toggle_show', { id: @announcement.id }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
        Announcement.find(@announcement.id).shown_on_homepage.should == @announcement.shown_on_homepage
      end
    end
  end

  describe "non-user" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake(nil, nil)
    end

    context "makes good requests:" do
      it "get index" do
        get 'index'
        response.should be_success
      end

      it "get notice" do
        get 'notice', { id: @announcement.id }
        response.should be_success
      end
    end

    context "makes bad requests:" do
      it "get notice" do
        get 'notice', { id: @announcement.id+1 }
        response.should be_redirect
        response.should redirect_to announcement_path
        flash[:errors].should include "Could not find announcement with id '#{@announcement.id+1}'"
      end

      it "get/post create" do
        get 'create'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+announcement.+create.*$/

        post 'create', { title: "Login problem?", description: "You should email your password to not_a_hacker@hotmail.com" }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+announcement.+create.*$/
        Announcement.where(title: "Login problem?", description: "You should email your password to not_a_hacker@hotmail.com").should be_blank
      end

      it "get/post edit" do
        get 'edit', { id: @announcement.id }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+announcement.+edit.*$/

        post 'edit', { id: @announcement.id , title: "Login problem?", description: "You should email your password to not_a_hacker@hotmail.com" }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+announcement.+edit.*$/
        announcement = Announcement.find(@announcement.id)
        announcement.title.should == @announcement.title
        announcement.description.should == @announcement.description
      end

      it "delete destroy" do
        delete 'destroy', { id: @announcement.id }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+announcement.+destroy.*$/
        Announcement.find(@announcement.id).should_not be_nil
      end

      it "post toggle_show" do
        post 'toggle_show', { id: @announcement.id }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+announcement.+toggle_show.*$/
        Announcement.find(@announcement.id).shown_on_homepage.should == @announcement.shown_on_homepage
      end
    end
  end  
end

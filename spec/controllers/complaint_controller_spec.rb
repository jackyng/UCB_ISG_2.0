require 'spec_helper'

describe ComplaintController do
  before(:each) do
    @root = Node.create(:name => Isg2::Application::ROOT_NODE_NAME)
    @user = User.create(calnetID: 181758)
    @admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
    @complaint = @user.complaints.create(
      ip_address: 4.times.map { rand(255) }.join("."),
      user_email: @user.fullname.split(" ").join("_") + "@berkeley.edu",
      title: "This is complaint of '#{@user.fullname}'"
    )
    @complaint.messages.create(
      user: @user,
      content: "This is the details of my (#{@user.fullname}) problem. Please help!"
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

      it "post update_status" do
        post 'update_status', { id: @complaint.id, status: "completed" }
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:error].should be_nil
        flash[:notice].should match /Status of Complaint '.+' updated\./
      end

      it "delete destroy" do
        delete 'destroy', { id: @complaint.id }
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:error].should be_nil
        flash[:notice].should match "Successfully removed complaint '.+'\."
      end

      it "get getComplaintData" do
        today = @complaint.created_at.to_date.to_s.gsub('-', '/')

        # some complaint is "new"
        get 'getComplaintData', format: :json
        response.should be_success
        body = JSON.parse(response.body)
        body.should include("totalComplaints")
        body.should include("totalResolved")
        body.should include("totalUnresolved")
        body["totalComplaints"].should include(today)
        body["totalComplaints"][today].should == 1
        body["totalResolved"].should include(today)
        body["totalResolved"][today].should == 0
        body["totalUnresolved"].should include(today)
        body["totalUnresolved"][today].should == 1

        # some complaint is "completed"
        @complaint.update_attributes(status: "completed")
        get 'getComplaintData', format: :json
        response.should be_success
        body = JSON.parse(response.body)
        body.should include("totalComplaints")
        body.should include("totalResolved")
        body.should include("totalUnresolved")
        body["totalComplaints"].should include(today)
        body["totalComplaints"][today].should == 1
        body["totalResolved"].should include(today)
        body["totalResolved"][today].should == 1
        body["totalUnresolved"].should include(today)
        body["totalUnresolved"][today].should == 0

        # none complaint is "completed" or "new"
        @complaint.update_attributes(status: "assigned")
        get 'getComplaintData', format: :json
        response.should be_success
        body = JSON.parse(response.body)
        body.should include("totalComplaints")
        body.should include("totalResolved")
        body.should include("totalUnresolved")
        body["totalComplaints"].should include(today)
        body["totalComplaints"][today].should == 1
        body["totalResolved"].should be_blank
        body["totalUnresolved"].should be_blank

        # No complaint at all
        Complaint.delete_all
        get 'getComplaintData'
        response.body.should == " "
      end

      it "get chart" do
        get 'chart'
        response.should be_success
      end
    end

    context "makes bad requests:" do
      it "post update_status" do
        # Bad id
        post 'update_status', { id: @complaint.id+1 }
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:error].should == "Could not find complaint with id '#{@complaint.id+1}'"

        # Missing status
        post 'update_status', { id: @complaint.id }
        response.should be_redirect
        flash[:error].should == "Parameter status missing"

        # Bad status
        post 'update_status', { id: @complaint.id, status: "blah" }
        response.should be_redirect
        flash[:error].should match /Couldn't update status of complaint .+ to '.*'/
      end

      it "get/post create" do
        get 'create'
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:error].should == "Only normal user can create complaint"

        post 'create', { title: "test complaint", description: "test complaint description" }
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:error].should == "Only normal user can create complaint"
      end

      it "delete destroy" do
        delete 'destroy', { id: @complaint.id+1 }
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:error].should == "Could not find complaint with id '#{@complaint.id+1}'"
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
      
      it "post update_status" do
        post 'update_status', { id: @complaint.id, status: "completed" }
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:error].should be_nil
        flash[:notice].should match /Status of Complaint '.+' updated\./
      end

      it "get/post create" do
        get 'create'
        response.should be_success

        post 'create', { title: "test complaint", description: "test complaint description" }
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:notice].should == "Successfully submitted complaint 'test complaint'."
        Complaint.find_by_title("test complaint").should_not be_nil
      end

      it "delete destroy" do
        delete 'destroy', { id: @complaint.id }
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:notice].should == "Successfully removed complaint '#{@complaint.title}'."
        Complaint.find_by_title(@complaint.title).should be_nil
      end
    end
    
    context "makes bad requests:" do
      it "post update_status" do
        # Bad id
        post 'update_status', { id: @complaint.id+1 }
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:error].should == "Could not find complaint with id '#{@complaint.id+1}'"

        # Missing status
        post 'update_status', { id: @complaint.id }
        response.should be_redirect
        flash[:error].should == "Parameter status missing"

        # Bad status
        post 'update_status', { id: @complaint.id, status: "blah" }
        response.should be_redirect
        flash[:error].should match /Couldn't update status of complaint .+ to '.*'/
      end

      it "post create" do
        post 'create', { title: "", description: "test complaint description" }
        response.should be_success
        flash[:error].should == "title error: can't be blank"
        Message.find_by_content("test complaint description").should be_nil

        post 'create', { title: "test complaint", description: "" }
        response.should be_success
        flash[:error].should == "content error: can't be blank"
        Complaint.find_by_title("test complaint").should be_nil
      end

      it "delete destroy" do
        delete 'destroy', { id: @complaint.id+1 }
        response.should be_redirect
        response.should redirect_to complaint_path
        flash[:error].should == "Could not find complaint with id '#{@complaint.id+1}'"
      end

      it "get chart" do
        get 'chart'
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end

      it "get getComplaintData" do
        get 'getComplaintData'
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end
    end
  end

  describe "non-user" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake(nil, nil)
    end

    context "can't make request:" do
      it "get index" do
        get 'index'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+complaint.*$/
      end
      
      it "post update_status" do
        post 'update_status', { id: @complaint.id, status: "completed" }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+complaint.*$/
      end

      it "get/post create" do
        get 'create'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+complaint.*$/

        post 'create'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+complaint.*$/
      end

      it "delete destroy" do
        delete 'destroy'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+complaint.*$/
      end

      it "get getComplaintData" do
        get 'getComplaintData'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+complaint.*$/
      end
    end
  end
end

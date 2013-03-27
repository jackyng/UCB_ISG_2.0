require 'spec_helper'

describe Complaint do
  before(:each) do
    User.create(:calnetID => 123456)
  end

  subject {
    Complaint.new(
      description: "desc",
      ip_address: "135.13.5.27",
      title: "title",
      user: User.find_by_calnetID(123456)
    )
  }

  it { should respond_to :title }
  it { should respond_to :description }
  it { should respond_to :ip_address }
  it { should respond_to :user_email }
  it { should respond_to :isResolved }
  it { should respond_to :user }
  it { should respond_to :user_id }

  context "should save with valid required arguments" do
    it "without optional user_email and isResolved" do
      subject.save.should == true
    end

    it "with optional false isResolved" do
      subject.isResolved = false
      subject.save.should == true
    end

    it "with optional true isResolved" do
      subject.isResolved = true
      subject.save.should == true
    end
  
    it "with optional email" do
      subject.user_email = "gau@example.com"
      subject.save.should == true
    end
  end

  context "should not save with invalid required arguments" do
    it "with nil or empty title" do
      subject.title = nil
      subject.save.should == false
      subject.errors.should include(:title)

      subject.title = ""
      subject.save.should == false
      subject.errors.should include(:title)
    end

    it "with nil or empty description" do
      subject.description = nil
      subject.save.should == false
      subject.errors.should include(:description)

      subject.description = ""
      subject.save.should == false
      subject.errors.should include(:description)
    end

    it "with nil or empty ip_address" do
      subject.ip_address = nil
      subject.save.should == false
      subject.errors.should include(:ip_address)

      subject.ip_address = ""
      subject.save.should == false
      subject.errors.should include(:ip_address)
    end

    it "without a user (author)" do
      subject.user = nil
      subject.save.should == false
      subject.errors.should include(:user)
    end
  end
end

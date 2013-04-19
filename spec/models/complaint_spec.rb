require 'spec_helper'

# TODO add more tests for messages

describe Complaint do
  before(:each) do
    User.create(calnetID: 181758)
  end

  subject {
    Complaint.new(
      ip_address: "135.13.5.27",
      title: "title",
      user: User.find_by_calnetID(181758)
    )
  }

  it { should respond_to :title }
  it { should respond_to :ip_address }
  it { should respond_to :user_email }
  it { should respond_to :status }
  it { should respond_to :user }
  it { should respond_to :user_id }
  it { should respond_to :admin }
  it { should respond_to :admin_id }
  it { should respond_to :messages }
  it { should_not respond_to :description }
  it { should_not respond_to :isResolved }

  context "should save with valid required arguments" do
    it "without optional user_email or :admin_id" do
      subject.save.should == true
    end

    it "with optional user_email" do
      subject.user_email = "gau@example.com"
      subject.save.should == true
    end

    it "with optional admin_id" do
      subject.admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
      subject.save.should == true
    end

    it "expect default value for status to be new" do
      subject.save
      subject.status.should == "new"
    end

    it "with expected status value" do
      ["new", "read", "assigned", "in progress", "completed"].each do |status|
        subject.status = status
        subject.save.should == true
      end
    end
  end

  context "should not save with invalid required arguments" do
    it "with nil or empty title" do
      [nil, ""].each do |title|
        subject.title = title
        subject.save.should == false
        subject.errors.should include(:title)
      end
    end

    it "with nil or empty ip_address" do
      [nil, ""].each do |ip_address|
        subject.ip_address = ip_address
        subject.save.should == false
        subject.errors.should include(:ip_address)
      end
    end

    it "without a user (author)" do
      subject.user = nil
      subject.save.should == false
      subject.errors.should include(:user)
    end

    it "with empty or invalid status" do
      # if status is nil, then the default_values will be called to set it to "new"
      ["", "blah"].each do |status|
        subject.status = status
        subject.save.should == false
        subject.errors.should include(:status)
      end
    end
  end
end

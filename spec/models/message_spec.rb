require 'spec_helper'

describe Message do
  before(:each) do
    @user  = User.create(calnetID: 181758)
    @admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
    @complaint = Complaint.create(
      user: @user,
      admin: @admin,
      title: "Complaint title",
      ip_address: "0.0.0.0",
      user_email: "gau@example.com"
    )
  end

  subject {
    Message.new(
      user: @user,
      complaint: @complaint,
      depth: 0,
      content: "I have this problem with Airbears authentication, how do I solve it?"
    )
  }

  it { should respond_to :complaint }
  it { should respond_to :complaint_id }
  it { should respond_to :user }
  it { should respond_to :user_id }
  it { should respond_to :admin }
  it { should respond_to :admin_id }
  it { should respond_to :depth }
  it { should respond_to :content }
  
  it "should save with valid required arguments" do
    subject.save.should == true
  end

  it "should save without setting manually depth" do
    subject.depth = nil
    subject.save.should == true
    subject.depth.should == 0
  end

  it "should not save negative depth" do
    subject.depth = -1
    subject.save.should == false
    subject.errors.should include(:depth)
    subject.errors[:depth].should include("must be greater than or equal to 0")
  end

  it "should start from depth 0 for a complaint" do
    subject.depth = 3
    subject.save.should == false
    subject.errors.should include(:depth)
    subject.errors[:depth].should include("No messages in complaint yet, so this message must start at depth 0")
  end

  it "should not save non-continuous depths" do
    subject.save
    message = Message.new(admin: @admin, complaint: @complaint, content: "blah", depth: 100)
    message.save.should == false
    message.errors.should include(:depth)
    message.errors[:depth].should include("Messages' depths of the same complaint must be continuous")
  end

  it "should not save with nil or empty content" do
    [nil, ""].each do |content|
      subject.content = content
      subject.save.should == false
      subject.errors.should include(:content)
      subject.errors[:content].should include("can't be blank")
    end
  end

  it "should save with admin as author" do
    subject.user = nil
    subject.admin = @admin
    subject.save.should == true
  end

  it "must have an author, either a user or an admin, but not both" do
    subject.admin = @admin
    subject.save.should == false
    subject.errors.should include(:author)
    subject.errors[:author].should include("Can only have one author, either user or admin, but not both")

    subject.user = nil
    subject.admin = nil
    subject.save.should == false
    subject.errors.should include(:author)
    subject.errors[:author].should include("Must have an author, either user or admin")
  end
end

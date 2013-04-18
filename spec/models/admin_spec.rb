require 'spec_helper'

describe Admin do
  subject { Admin.new(calnetID: 181758, email: "gau@example.com") }

  it { should respond_to :fullname }
  it { should respond_to :calnetID }
  it { should respond_to :email }
  it { should respond_to :last_request_time }

  it "should save with calnetID and email" do
    subject.save.should == true
  end

  it "should save with calnetID and email" do
    subject.save.should == true
  end

  it "should not save without calnetID" do
    subject.calnetID = nil
    subject.save.should == false
    subject.errors.should include(:calnetID)
  end

  it "should not save with empty or nil email" do
    [nil, ""].each do |email|
      subject.email = email
      subject.save.should == false
      subject.errors.should include(:email)
    end
  end

  it "should not have duplicate calnetID" do
    subject.save.should == true
    u = Admin.new(calnetID: 181758)
    u.save.should == false
    u.errors.should include(:calnetID)
  end
end

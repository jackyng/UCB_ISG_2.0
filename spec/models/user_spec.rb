require 'spec_helper'

describe User do
  subject { User.new(calnetID: 181758) }

  it { should respond_to :fullname }
  it { should respond_to :calnetID }
  it { should respond_to :email }
  it { should respond_to :last_request_time }
  it { should_not respond_to :isAdmin }

  it "should save with calnetID without manually setting email" do
    subject.save.should == true
  end

  it "should save with calnetID and email" do
    subject.email = "gau@example.com"
    subject.save.should == true
  end

  it "should not save without calnetID" do
    subject.calnetID = nil
    subject.save.should == false
  end

  it "should not have duplicate calnetID" do
    subject.save.should == true
    u = User.new(calnetID: 181758)
    u.save.should == false
    u.errors.should include(:calnetID)
  end
end

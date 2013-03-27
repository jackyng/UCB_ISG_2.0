require 'spec_helper'

describe User do
  subject { User.new(calnetID: 123456) }

  it { should respond_to :isAdmin }
  it { should respond_to :calnetID }
  it { should respond_to :email }

  it "should save with calnetID without email and isAdmin must be false without manually setting it" do
    subject.save.should == true
    subject.isAdmin.should == false
  end

  it "should save with calnetID for admin without email" do
    subject.isAdmin = true
    subject.save.should == true
    subject.isAdmin.should == true
  end

  it "should save with calnetID and email" do
    subject.email = "gau@example.com"
    subject.save.should == true
  end

  it "should save with calnetID for admin with email" do
    subject.isAdmin = true
    subject.email = "gau@example.com"
    subject.save.should == true
    subject.isAdmin.should == true
  end

  it "should not save without calnetID" do
    subject.calnetID = nil
    subject.save.should == false
  end

  it "should not have duplicate calnetID" do
    subject.save.should == true
    u = User.new(calnetID: 123456)
    u.save.should == false
    u.errors.should include(:calnetID)
  end
end

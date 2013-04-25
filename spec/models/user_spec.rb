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
    u = User.new(calnetID: subject.calnetID)
    u.save.should == false
    u.errors.should include(:calnetID)
  end

  it "should not save empty email" do
    subject.email = ""
    subject.save.should == false
    subject.errors.should include(:email)
    subject.errors[:email].should include("Email cannot be an empty string")
  end

  it "should not save wihtout valid calnetID" do
    ldap = stub(bind: true, search: stub(first: nil))
    Net::LDAP.stub(:new).and_return(ldap)
    subject.save.should == false
    subject.errors.should include(:ldap)
    subject.errors[:ldap].should include("Cannot find calnetID #{subject.calnetID} in LDAP")
    subject.errors.should include(:fullname)
    subject.errors[:fullname].should include("can't be blank")
  end
end

require 'spec_helper'

describe Request do
  subject { Request.new(ip_address: "0.0.0.0") }

  it { should respond_to :ip_address }
  it { should respond_to :request_time }
  it { should respond_to :isRegistered }

  it "should save with valid required arguments" do
    subject.save.should == true
  end

  it "should not have nil or empty ip_address" do
    [nil, ""].each do |ip_address|
      subject.ip_address = ip_address
      subject.save.should == false
      subject.errors.should include(:ip_address)
      subject.errors[:ip_address].should include("can't be blank")
    end
  end

  it "should default request_time to now if nil" do
    subject.request_time = nil
    subject.save.should == true
    subject.request_time.should > 2.seconds.ago
  end

  it "should default isRegistered to false if nil" do
    subject.isRegistered = nil
    subject.save.should == true
    subject.isRegistered.should == false
  end

  it "should still save if isRegistered is true" do
    subject.isRegistered = true
    subject.save.should == true
    subject.isRegistered.should == true
  end
end

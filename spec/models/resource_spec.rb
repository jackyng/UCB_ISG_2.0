require 'spec_helper'

describe Resource do
  subject { Resource.new(name: "res1", url: "res1.com", description: "This is res1") }

  it { should respond_to :name }
  it { should respond_to :url }
  it { should respond_to :count }
  it { should respond_to :content }
  it { should respond_to :description }

  it "should save with valid arguments" do
    subject.save.should == true
  end

  it "should have a name" do
    subject.name = nil
    subject.should_not be_valid
  end

  it "should not have empty name" do
    subject.name = ""
    subject.should_not be_valid
  end

  it "should have a url" do
    subject.url = nil
    subject.should_not be_valid
  end

  it "should not have empty url" do
    subject.url = ""
    subject.should_not be_valid
  end

  it "should save with empty description" do
    [nil, ""].each do |description|
      subject.description = description
      subject.save.should == true
    end
  end

  it "should default count to 0 even without manually setting it" do
    subject.save
    res = Resource.where(name: "res1", url: "res1.com")
    res.should_not be_nil
    res.should_not be_empty
    res[0].count.should == 0
  end

  it "should not have duplicate name" do
    subject.save
    another_resource = Resource.new(name: "res1", url: "1")
    another_resource.save.should == false
  end

  it "should not have duplicate url" do
    subject.save
    another_resource = Resource.new(name: "blah", url: "res1.com")
    another_resource.save.should == false
    another_resource.errors.should include(:url)
  end
end
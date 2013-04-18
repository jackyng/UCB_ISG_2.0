require 'spec_helper'

describe Node do
  subject { Node.new(name: "node1", description: "This is node1") }

  it { should respond_to :name }
  it { should respond_to :description }

  it "should save with valid argument" do
    subject.save.should == true
  end

  it "should not save with nil or empty name" do
    [nil, ""].each do |name|
      subject.name = name
      subject.save.should == false
      subject.errors.should include(:name)
    end
  end

  it "should not save with nil or empty description" do
    [nil, ""].each do |description|
      subject.description = description
      subject.save.should == false
      subject.errors.should include(:description)
    end
  end

  it "should not save with duplicate name among its siblings" do
    parent = Node.create(name: "parent", description: "This is the parent node")
    subject.parent = parent
    subject.save

    another_sibling = Node.new(name: "node1", description: "something else")
    another_sibling.parent = parent
    another_sibling.valid?
    another_sibling.errors.should include(:name)
  end
end
require 'spec_helper'
require 'node'

describe "A Node" do
  subject { Node.new(:name => "node1") }

  it { should respond_to :name }

  it "should have a name" do
    subject.name = nil
    subject.should_not be_valid
  end

  it "should not have empty name" do
    subject.name = ""
    subject.should_not be_valid
  end

  it "should not have unique name among its siblings" do
    parent = Node.create(:name => "parent")
    subject.parent = parent
    subject.save

    another_sibling = Node.new(:name => "node1")
    another_sibling.parent = parent
    another_sibling.valid?
    another_sibling.errors.should include(:name)
  end
end
require 'spec_helper'

describe Announcement do
  before(:each) do
    @admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
  end

  subject {
    Announcement.new(
      admin: @admin,
      title: "Announcement 1",
      description: "This is the first ever announcement!"
    )
  }

  it { should respond_to :admin }
  it { should respond_to :admin_id }
  it { should respond_to :title }
  it { should respond_to :description }

  it "should save with valid required arguments" do
    subject.save.should == true
  end

  it "must have an admin" do
    subject.admin = nil
    subject.save.should == false
    subject.errors.should include(:admin)
    subject.errors[:admin].should include("can't be blank")
  end

  it "should not have nil or empty title" do
    [nil, ""].each do |title|
      subject.title = title
      subject.save.should == false
      subject.errors.should include(:title)
      subject.errors[:title].should include("can't be blank")
    end
  end

  it "should not have nil or empty description" do
    [nil, ""].each do |description|
      subject.description = description
      subject.save.should == false
      subject.errors.should include(:description)
      subject.errors[:description].should include("can't be blank")
    end
  end
end

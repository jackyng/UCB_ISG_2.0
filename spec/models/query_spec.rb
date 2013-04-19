require 'spec_helper'

describe Query do
  before(:each) do
    @admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
  end

  subject {
    Query.new(
      admin: @admin,
      description: "count number of user",
      query_string: "SELECT COUNT(*) FROM USER;"
    )
  }

  it { should respond_to :admin }
  it { should respond_to :admin_id }
  it { should respond_to :description }
  it { should respond_to :query_string }

  it "should save with valid required arguments" do
    subject.save.should == true
  end

  it "must have an admin" do
    subject.admin = nil
    subject.save.should == false
    subject.errors.should include(:admin)
    subject.errors[:admin].should include("can't be blank")
  end

  it "should not have nil or empty description" do
    [nil, ""].each do |description|
      subject.description = description
      subject.save.should == false
      subject.errors.should include(:description)
      subject.errors[:description].should include("can't be blank")
    end
  end

  it "should not have nil or empty query_string" do
    [nil, ""].each do |query_string|
      subject.query_string = query_string
      subject.save.should == false
      subject.errors.should include(:query_string)
      subject.errors[:query_string].should include("can't be blank")
    end
  end
end

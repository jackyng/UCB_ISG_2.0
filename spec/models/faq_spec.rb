require 'spec_helper'

describe Faq do
  before(:each) do
    @admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
  end

  subject {
    Faq.new(
      admin: @admin,
      question: "So" + "o"*255 + ", I have a problem with wifi?",
      answer: "So" + "o"*255 + ", just reset your device"
    )
  }

  it { should respond_to :admin }
  it { should respond_to :admin_id }
  it { should respond_to :question }
  it { should respond_to :answer }

  it "should save with valid required arguments" do
    subject.save.should == true
  end

  it "must have an admin" do
    subject.admin = nil
    subject.save.should == false
    subject.errors.should include(:admin)
    subject.errors[:admin].should include("can't be blank")
  end

  it "should not have nil or empty question" do
    [nil, ""].each do |question|
      subject.question = question
      subject.save.should == false
      subject.errors.should include(:question)
      subject.errors[:question].should include("can't be blank")
    end
  end

  it "should not have nil or empty answer" do
    [nil, ""].each do |answer|
      subject.answer = answer
      subject.save.should == false
      subject.errors.should include(:answer)
      subject.errors[:answer].should include("can't be blank")
    end
  end
end

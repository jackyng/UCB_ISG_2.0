class Faq < ActiveRecord::Base
  belongs_to :admin

  attr_accessible :admin, :answer, :question
  validates :admin, :answer, :question, :presence => true
end

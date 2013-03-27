class Complaint < ActiveRecord::Base
  belongs_to :user
  attr_accessible :description, :ip_address, :isResolved, :title, :user, :user_email

  validates :description, :ip_address, :title, :user, :presence => true
  validates :isResolved, :inclusion => { :in => [true, false] }

  before_save :default_values
  before_create :default_values
  before_validation :default_values
  def default_values
    self.isResolved = false if self.isResolved.nil?
    return
  end
end

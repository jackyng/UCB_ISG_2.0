class Complaint < ActiveRecord::Base
  belongs_to :user
  belongs_to :admin
  has_many :messages

  attr_accessible :ip_address, :status, :title, :user, :admin, :user_email

  validates :ip_address, :status, :title, :user, :presence => true
  validates :status, :inclusion => { :in => ["new", "read", "assigned", "in progress", "completed"] }

  before_save :default_values
  before_create :default_values
  before_validation :default_values
  def default_values
    self.status = "new" if self.status.nil?
    return
  end
end

class User < ActiveRecord::Base
  has_many :complaints

  attr_accessible :calnetID, :email, :isAdmin

  validates :calnetID, :presence => true, :uniqueness => true
  validates :isAdmin, :inclusion => { :in => [true, false] }

  before_save :default_values
  before_create :default_values
  before_validation :default_values
  def default_values
    self.isAdmin = false if self.isAdmin.nil?
    return
  end
end

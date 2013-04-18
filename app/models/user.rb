class NilOrNonEmptyEmailValidator < ActiveModel::Validator
  def validate(record)
    if not record.email.nil? and record.email == ""
      record.errors[:email] << "Email cannot be an empty string"
      return false
    end
    return true
  end
end

class User < ActiveRecord::Base
  has_many :complaints

  attr_accessible :calnetID, :fullname, :email, :last_request_time

  validates :calnetID, :presence => true, :uniqueness => true
  validates :fullname, :presence => true
  validates_with NilOrNonEmptyEmailValidator

  before_save :default_values
  before_validation :default_values
  def default_values
    unless self.calnetID.nil?
      self.fullname = ldap_lookup(self.calnetID) if self.fullname.nil?
    end
    return
  end
end

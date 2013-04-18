class Admin < ActiveRecord::Base
  attr_accessible :calnetID, :email, :fullname, :last_request_time
  validates :calnetID, :email, :presence => true, :uniqueness => true

  validates :fullname, :presence => true

  before_save :default_values
  before_validation :default_values
  def default_values
    unless self.calnetID.nil?
      self.fullname = ldap_lookup(self.calnetID) if self.fullname.nil?
    end
    return
  end
end

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
  has_many :messages

  attr_accessible :calnetID, :fullname, :email, :last_request_time

  validates :calnetID, :presence => true, :uniqueness => true
  validates :fullname, :presence => true
  validates_with NilOrNonEmptyEmailValidator

  before_save :default_values
  before_create :default_values
  before_validation :default_values
  def default_values
    unless self.calnetID.nil?
      self.fullname = ldap_lookup(self.calnetID) if self.fullname.nil?
    end
    return
  end
end

def ldap_lookup(calnet_id)
  unless calnet_id.nil?
    ldap = Net::LDAP.new(
      host: 'ldap.berkeley.edu',
      port: 389
    )
    if ldap.bind
      ldap.search(
        base:          "ou=people,dc=berkeley,dc=edu",
        filter:        Net::LDAP::Filter.eq( "uid", calnet_id.to_s ),
        attributes:    %w[ displayName ],
        return_result: true
      ).first.displayName.first
    else
      flash[:error] = "Can't connect to LDAP to get user's name"
    end
  end
end
class NilOrNonEmptyEmailValidator < ActiveModel::Validator
  def validate(record)
    if record.email and record.email == ""
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
      self.fullname = ldap_lookup(self.calnetID) if self.fullname.nil? or self.fullname.empty?
    end
    return
  end

  def update_name
    begin
      self.fullname = ldap_lookup(self.calnetID)
    rescue Exception
    end
  end

  private
  def ldap_lookup(calnetID)
    unless calnetID.nil?
      ldap = Net::LDAP.new(
        host: 'ldap.berkeley.edu',
        port: 389
      )
      if ldap.bind
        ldap_entry = ldap.search(
          base:          "ou=people,dc=berkeley,dc=edu",
          filter:        Net::LDAP::Filter.eq( "uid", calnetID.to_s ),
          attributes:    %w[ displayName ],
          return_result: true
        ).first
        if ldap_entry
          return ldap_entry.displayName.first
        else
          self.errors[:ldap] << "Cannot find calnetID #{calnetID} in LDAP"
        end
      end
    end
    return ""
  end
end

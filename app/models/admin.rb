class Admin < ActiveRecord::Base
  has_many :complaints
  has_many :messages
  has_many :queries
  has_many :announcements
  has_many :faqs

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
      else
        self.errors[:ldap] << "Can't connect to LDAP to get user's name"
      end
    end
  end
end
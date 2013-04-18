class Admin < ActiveRecord::Base
  has_many :complaints
  has_many :messages
  has_many :queries

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
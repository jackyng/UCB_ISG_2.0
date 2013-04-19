class Request < ActiveRecord::Base
  attr_accessible :ip_address, :isRegistered, :request_time

  validates :ip_address, :request_time, :presence => true

  before_save :default_values
  before_create :default_values
  before_validation :default_values
  def default_values
    self.isRegistered = false if self.isRegistered.nil?
    self.request_time = Time.now if self.request_time.nil?
    return
  end
end

class Resource < ActiveRecord::Base
  belongs_to :node
  attr_accessible :count, :name, :url

  validates :name, :presence => true, :uniqueness => true
  validates :count, :presence => true
  validates :url, :presence => true, :uniqueness => true

  before_save :default_values
  before_validation :default_values
  def default_values
    self.count = 0 if self.count.nil?
  end
end

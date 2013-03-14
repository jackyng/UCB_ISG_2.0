class Resource < ActiveRecord::Base
  belongs_to :node
  attr_accessible :count, :name, :url

  validates :name, :presence => true, :uniqueness => true
  validates :count, :presence => true
  validates :url, :presence => true, :uniqueness => true
end

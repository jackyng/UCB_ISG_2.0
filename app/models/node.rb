class Node < ActiveRecord::Base
  has_ancestry
  has_many :resources

 	attr_accessible :name
  validates :name, :presence => true
end

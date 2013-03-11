class Node < ActiveRecord::Base
  has_ancestry

 	attr_accessible :name
  validates :name, :presence => true
end

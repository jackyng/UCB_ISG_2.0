class Node < ActiveRecord::Base
  has_one :parenthood
  has_many :nodes, :through => :parenthood
  has_one :resource

 	attr_accessible :name
end

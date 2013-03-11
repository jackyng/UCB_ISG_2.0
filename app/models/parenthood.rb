class Parenthood < ActiveRecord::Base
  belongs_to :node
  belongs_to :parent, :class_name => "Node"
  
  attr_accessible :node_id, :parent_id
end

class Resource < ActiveRecord::Base
  belongs_to :node
  attr_accessible :count, :name, :url
end

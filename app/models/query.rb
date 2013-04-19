class Query < ActiveRecord::Base
  belongs_to :admin

  attr_accessible :admin, :description, :query_string
  validates :admin, :description, :query_string, :presence => true
end

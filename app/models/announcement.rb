class Announcement < ActiveRecord::Base
  belongs_to :admin

  attr_accessible :admin, :title, :description
  validates :admin, :title, :description, :presence => true
end

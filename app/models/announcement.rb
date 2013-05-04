class Announcement < ActiveRecord::Base
  belongs_to :admin

  attr_accessible :admin, :title, :description, :shown_on_homepage
  validates :admin, :title, :description, :presence => true
  validates_inclusion_of :shown_on_homepage, in: [true, false]

  before_save :default_values
  before_create :default_values
  before_validation :default_values
  def default_values
    self.shown_on_homepage = true if self.shown_on_homepage.nil?
    return
  end
end

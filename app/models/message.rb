class AuthorValidator < ActiveModel::Validator
  def validate(record)
    if record.admin.nil? and record.user.nil?
      record.errors[:author] << "Must have an author, either user or admin"
      return false
    end

    unless record.admin.nil? or record.user.nil?
      record.errors[:author] << "Can only have one author, either user or admin, but not both"
      return false
    end

    return true
  end
end

# TODO add continuous from 0 validator
class ContinuousDepthFromZeroValidator < ActiveModel::Validator
  def validate(record)
    depths = Message.ordered_by_complaint(record.complaint_id).map(&:depth)
    
    if depths.nil? or depths.empty?
      if record.depth != 0
        record.errors[:depth] << "No messages in complaint yet, so this message must start at depth 0"
        return false
      end
    elsif record.depth == 0
      unless depths[0] == 0
        record.errors[:depth] << "Messages of a complaint must start from depth 0"
        return false
      end
    elsif record.depth != depths.last+1
      record.errors[:depth] << "Messages' depths of the same complaint must be continuous"
      return false
    end
    return true
  end
end

class Message < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :user
  belongs_to :admin
  
  attr_accessible :complaint, :user, :admin, :content, :depth

  validates :content, :depth, :presence => true
  validates :depth, :numericality => { :greater_than_or_equal_to => 0 }
  validates_with AuthorValidator
  validates_with ContinuousDepthFromZeroValidator

  scope :ordered_by_complaint, lambda { |complaint_id| where(complaint_id: complaint_id).order("depth asc") }

  before_save :default_values
  before_create :default_values
  before_validation :default_values
  def default_values
    self.depth = 0 if self.depth.nil?
    return
  end
end
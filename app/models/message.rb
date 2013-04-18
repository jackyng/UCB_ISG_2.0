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

class Message < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :user
  belongs_to :admin
  
  attr_accessible :complaint, :user, :admin, :content, :depth

  validates :content, :depth, :presence => true
  validates :depth, :numericality => { :greater_than_or_equal_to => 0 }
  validates_with AuthorValidator
end

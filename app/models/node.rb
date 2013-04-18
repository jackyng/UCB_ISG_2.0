class UniqueNameAmongSiblingsValidator < ActiveModel::Validator
  def validate(record)
    unless record.parent.nil?
      record.parent.children.each do |child|
        if record.name == child.name
          record.errors[:name] << 'Name must be unique among siblings'
          return false
        end
      end
    end
  end
end

class Node < ActiveRecord::Base
  has_ancestry
  has_many :resources

 	attr_accessible :name, :description, :parent
  validates :name, :description, :presence => true
  validates_with UniqueNameAmongSiblingsValidator
end
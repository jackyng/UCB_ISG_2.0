class RemoveIsResolvedAndDescriptionFromComplaints < ActiveRecord::Migration
  def up
    remove_column :complaints, :isResolved
    remove_column :complaints, :description
  end

  def down
    add_column :complaints, :description, :string
    add_column :complaints, :isResolved, :boolean
  end
end

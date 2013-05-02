class AddDescriptionToResources < ActiveRecord::Migration
  def up
    add_column :resources, :description, :text
  end

  def down
    remove_column :resources, :description
  end
end

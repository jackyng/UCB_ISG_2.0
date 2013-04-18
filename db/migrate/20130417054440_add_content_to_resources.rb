class AddContentToResources < ActiveRecord::Migration
  def change
    add_column :resources, :content, :text
  end
end

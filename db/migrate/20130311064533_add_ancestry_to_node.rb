class AddAncestryToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :ancestry, :string
  end
  
  def up
    add_index :nodes, :ancestry
  end

  def down
    remove_index :nodes, :ancestry
  end
end

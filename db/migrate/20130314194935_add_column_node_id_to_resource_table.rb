class AddColumnNodeIdToResourceTable < ActiveRecord::Migration
  def up
    add_column :resources, :node_id, :integer
  end

  def down
    remove_column :resources, :node_id
  end
end

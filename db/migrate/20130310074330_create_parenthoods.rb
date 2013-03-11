class CreateParenthoods < ActiveRecord::Migration
  def change
    create_table :parenthoods do |t|
      t.integer :node_id
      t.integer :parent_id

      t.timestamps
    end
  end
end

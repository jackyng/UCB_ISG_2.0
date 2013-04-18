class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :complaint
      t.references :user
      t.references :admin
      t.integer :depth
      t.text :content

      t.timestamps
    end
    add_index :messages, :complaint_id
    add_index :messages, :user_id
    add_index :messages, :admin_id
  end
end

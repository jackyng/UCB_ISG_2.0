class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.references :admin
      t.text :description
      t.text :query_string

      t.timestamps
    end
    add_index :queries, :admin_id
  end
end

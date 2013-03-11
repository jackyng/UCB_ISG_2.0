class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name
      t.string :url
      t.integer :count

      t.timestamps
    end
  end
end

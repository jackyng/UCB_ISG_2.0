class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.boolean :isAdmin
      t.integer :calnetID
      t.string :email

      t.timestamps
    end
  end
end

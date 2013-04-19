class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string :fullname
      t.integer :calnetID
      t.string :email
      t.datetime :last_request_time

      t.timestamps
    end
  end
end

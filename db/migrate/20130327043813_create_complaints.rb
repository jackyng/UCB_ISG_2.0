class CreateComplaints < ActiveRecord::Migration
  def change
    create_table :complaints do |t|
      t.string :title
      t.string :description
      t.string :ip_address
      t.string :user_email
      t.boolean :isResolved
      t.references :user

      t.timestamps
    end
  end
end

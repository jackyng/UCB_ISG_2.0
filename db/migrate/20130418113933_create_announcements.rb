class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.references :admin
      t.string :title
      t.text :description

      t.timestamps
    end
    add_index :announcements, :admin_id
  end
end

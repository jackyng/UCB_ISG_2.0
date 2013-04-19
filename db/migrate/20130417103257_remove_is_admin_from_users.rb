class RemoveIsAdminFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :isAdmin
  end

  def down
    add_column :users, :isAdmin, :boolean
  end
end

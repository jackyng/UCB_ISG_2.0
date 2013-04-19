class AddAdminIdToComplaints < ActiveRecord::Migration
  def change
    add_column :complaints, :admin_id, :integer
  end
end

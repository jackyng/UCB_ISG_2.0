class AddStatusToComplaints < ActiveRecord::Migration
  def change
    add_column :complaints, :status, :string
  end
end

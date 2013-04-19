class AddFullnameAndLastRequestTimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fullname, :string
    add_column :users, :last_request_time, :datetime
  end
end

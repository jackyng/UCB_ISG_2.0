class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :ip_address
      t.datetime :request_time
      t.boolean :isRegistered

      t.timestamps
    end
  end
end

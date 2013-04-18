class AddDescriptionToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :description, :string
  end
end

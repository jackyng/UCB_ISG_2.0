class CreateFaqs < ActiveRecord::Migration
  def change
    create_table :faqs do |t|
      t.references :admin
      t.text :question
      t.text :answer

      t.timestamps
    end
    add_index :faqs, :admin_id
  end
end

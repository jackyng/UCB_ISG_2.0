class AddShownOnHomepageToAnnouncement < ActiveRecord::Migration
  def up
    add_column :announcements, :shown_on_homepage, :boolean
  end

  def down
    remove_column :announcements, :shown_on_homepage
  end
end

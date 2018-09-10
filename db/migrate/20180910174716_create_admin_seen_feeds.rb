class CreateAdminSeenFeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_seen_feeds do |t|
      t.integer :admin_id
      t.integer :admin_feed_id

      t.timestamps
    end
  end
end

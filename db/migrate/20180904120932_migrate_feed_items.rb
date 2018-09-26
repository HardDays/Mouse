class MigrateFeedItems < ActiveRecord::Migration[5.1]
  def change
    drop_table :account_updates
    drop_table :event_updates

    remove_column :feed_items, :account_update_id
    remove_column :feed_items, :event_update_id
  end
end

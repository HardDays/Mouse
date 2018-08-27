class CreateFeedItems < ActiveRecord::Migration[5.1]
  def change
    create_table :feed_items do |t|
      t.integer :event_update_id
      t.integer :account_update_id

      t.timestamps
    end
  end
end

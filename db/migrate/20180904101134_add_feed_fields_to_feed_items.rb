class AddFeedFieldsToFeedItems < ActiveRecord::Migration[5.1]
  def change
    add_column :feed_items, :account_id, :integer
    add_column :feed_items, :event_id, :integer
    add_column :feed_items, :updated_by, :integer
    add_column :feed_items, :action, :integer
    add_column :feed_items, :field, :integer
    add_column :feed_items, :value, :string
  end
end

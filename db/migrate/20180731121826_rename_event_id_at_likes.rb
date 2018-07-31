class RenameEventIdAtLikes < ActiveRecord::Migration[5.1]
  def change
    rename_column :likes, :event_id, :feed_item_id
  end
end

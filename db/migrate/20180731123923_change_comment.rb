class ChangeComment < ActiveRecord::Migration[5.1]
  def change
    rename_column :comments, :event_id, :feed_item_id
  end
end

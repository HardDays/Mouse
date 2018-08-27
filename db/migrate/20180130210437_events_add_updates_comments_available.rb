class EventsAddUpdatesCommentsAvailable < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :updates_available, :boolean, default: false
    add_column :events, :comments_available, :boolean, default: false
  end
end

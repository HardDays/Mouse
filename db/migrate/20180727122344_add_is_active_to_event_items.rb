class AddIsActiveToEventItems < ActiveRecord::Migration[5.1]
  def change
    add_column :artist_events, :is_active, :boolean, default: false
    add_column :venue_events, :is_active, :boolean, default: false
  end
end

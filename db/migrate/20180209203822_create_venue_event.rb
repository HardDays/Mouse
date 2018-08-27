class CreateVenueEvent < ActiveRecord::Migration[5.1]
  def change
    create_table :venue_events do |t|
      t.integer :venue_id
      t.integer :event_id
    end
  end
end

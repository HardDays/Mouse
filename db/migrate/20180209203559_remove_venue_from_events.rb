class RemoveVenueFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :venue_id, :string
  end
end

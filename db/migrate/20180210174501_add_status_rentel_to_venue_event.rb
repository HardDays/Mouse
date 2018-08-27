class AddStatusRentelToVenueEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :venue_events, :status, :integer
    add_column :venue_events, :rental_from, :datetime
    add_column :venue_events, :rental_to, :datetime
    add_column :venue_events, :reason, :string
    add_column :venue_events, :created_at, :datetime
    add_column :venue_events, :updated_at, :datetime
  end
end

class AddAboutToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :event_month, :integer
    add_column :events, :event_year, :integer
    add_column :events, :event_length, :integer
    add_column :events, :event_time, :integer
    add_column :events, :crowdfunding_event, :boolean
    add_column :events, :city_lat, :float
    add_column :events, :city_lng, :float
    add_column :events, :artists_number, :integer
  end
end

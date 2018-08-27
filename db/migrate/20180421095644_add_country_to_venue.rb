class AddCountryToVenue < ActiveRecord::Migration[5.1]
  def change
    add_column :public_venues, :country, :string
    add_column :public_venues, :city, :string
    add_column :public_venues, :state, :string
    add_column :public_venues, :zipcode, :integer
    add_column :public_venues, :minimum_notice, :integer
    add_column :public_venues, :is_flexible, :boolean
    add_column :public_venues, :price_for_daytime, :integer
    add_column :public_venues, :price_for_nighttime, :integer
    add_column :public_venues, :performance_time_from, :time
    add_column :public_venues, :performance_time_to, :time
  end
end

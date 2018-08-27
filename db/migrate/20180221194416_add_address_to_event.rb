class AddAddressToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :address, :string
    add_column :events, :old_address, :string
    add_column :events, :old_city_lat, :float
    add_column :events, :old_city_lng, :float
  end
end

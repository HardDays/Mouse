class AddStreetToPublicVenue < ActiveRecord::Migration[5.1]
  def change
    add_column :public_venues, :street, :string
  end
end

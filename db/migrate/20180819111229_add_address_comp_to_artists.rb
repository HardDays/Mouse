class AddAddressCompToArtists < ActiveRecord::Migration[5.1]
  def change
    add_column :artists, :street, :string
    add_column :artists, :city, :string
    add_column :artists, :state, :string
    add_column :artists, :country, :string
    add_column :artists, :zipcode, :integer
  end
end

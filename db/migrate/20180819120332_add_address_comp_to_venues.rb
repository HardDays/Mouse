class AddAddressCompToVenues < ActiveRecord::Migration[5.1]
  def change
    add_column :venues, :street, :string
    add_column :venues, :city, :string
    add_column :venues, :state, :string
    add_column :venues, :country, :string
    add_column :venues, :zipcode, :integer
  end
end

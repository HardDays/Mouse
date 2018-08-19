class AddAddressCompToFans < ActiveRecord::Migration[5.1]
  def change
    add_column :fans, :street, :string
    add_column :fans, :city, :string
    add_column :fans, :state, :string
    add_column :fans, :country, :string
    add_column :fans, :zipcode, :integer
  end
end

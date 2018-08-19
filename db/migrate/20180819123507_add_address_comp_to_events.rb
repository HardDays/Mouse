class AddAddressCompToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :street, :string
    add_column :events, :city, :string
    add_column :events, :state, :string
    add_column :events, :country, :string
    add_column :events, :zipcode, :integer
  end
end

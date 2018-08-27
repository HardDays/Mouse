class AddOtherAddressToPublicVenue < ActiveRecord::Migration[5.1]
  def change
    add_column :public_venues, :other_address, :string, default: ""
  end
end

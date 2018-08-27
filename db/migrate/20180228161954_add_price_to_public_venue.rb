class AddPriceToPublicVenue < ActiveRecord::Migration[5.1]
  def change
    add_column :public_venues, :price, :integer
  end
end

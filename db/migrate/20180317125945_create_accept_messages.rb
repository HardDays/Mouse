class CreateAcceptMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :accept_messages do |t|
      t.datetime :preferred_date_from
      t.datetime :preferred_date_to
      t.integer :price
      t.integer :travel_price
      t.integer :hotel_price
      t.integer :transportation_price
      t.integer :band_price
      t.integer :other_price

      t.timestamps
    end
  end
end

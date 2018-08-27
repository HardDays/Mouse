class CreateAgreedDateTimeAndPrices < ActiveRecord::Migration[5.1]
  def change
    create_table :agreed_date_time_and_prices do |t|
      t.datetime :datetime_from
      t.datetime :datetime_to
      t.integer :price
      t.integer :venue_event_id
      t.integer :artist_event_id

      t.timestamps
    end
  end
end

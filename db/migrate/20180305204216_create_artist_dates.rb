class CreateArtistDates < ActiveRecord::Migration[5.1]
  def change
    create_table :artist_dates do |t|
      t.integer :artist_id
      t.date :begin_date
      t.date :end_date

      t.timestamps
    end
  end
end

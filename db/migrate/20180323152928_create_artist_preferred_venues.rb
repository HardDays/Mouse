class CreateArtistPreferredVenues < ActiveRecord::Migration[5.1]
  def change
    create_table :artist_preferred_venues do |t|
      t.integer :type_of_venue
      t.integer :artist_id

      t.timestamps
    end
  end
end

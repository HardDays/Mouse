class CreateVenueGenres < ActiveRecord::Migration[5.1]
  def change
    create_table :venue_genres do |t|
      t.integer :venue_id
      t.integer :genre

      t.timestamps
    end
  end
end

class CreateArtistRiders < ActiveRecord::Migration[5.1]
  def change
    create_table :artist_riders do |t|
      t.integer :artist_id
      t.integer :rider_type
      t.string :uploaded_file
      t.string :description, max: 2000
      t.boolean :is_flexible, default: false

      t.timestamps
    end
  end
end

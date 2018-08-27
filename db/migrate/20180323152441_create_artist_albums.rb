class CreateArtistAlbums < ActiveRecord::Migration[5.1]
  def change
    create_table :artist_albums do |t|
      t.integer :artist_id
      t.string :album_name
      t.string :album_artwork
      t.string :album_link

      t.timestamps
    end
  end
end

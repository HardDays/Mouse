class AddAmeilToArtist < ActiveRecord::Migration[5.1]
  def change
    add_column :artists, :artist_email, :string
  end
end

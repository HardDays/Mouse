class AddUploadedFileBase64ToArtistRiders < ActiveRecord::Migration[5.1]
  def change
    add_column :artist_riders, :uploaded_file_base64, :string
  end
end

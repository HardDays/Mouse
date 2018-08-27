class AddSocialToArtist < ActiveRecord::Migration[5.1]
  def change
    add_column :artists, :facebook, :string
    add_column :artists, :twitter, :string
    add_column :artists, :instagram, :string
    add_column :artists, :snapchat, :string
    add_column :artists, :spotify, :string
    add_column :artists, :soundcloud, :string
    add_column :artists, :youtube, :string
  end
end

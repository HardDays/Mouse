class AddFieldsToArtistInvite < ActiveRecord::Migration[5.1]
  def change
    add_column :artist_invites, :email, :string
    add_column :artist_invites, :name, :string
    add_column :artist_invites, :facebook, :string
    add_column :artist_invites, :twitter, :string
    add_column :artist_invites, :youtube, :string
    add_column :artist_invites, :vk, :string
  end
end

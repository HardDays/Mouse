class AddFieldsToVenueInvites < ActiveRecord::Migration[5.1]
  def change
    add_column :venue_invites, :email, :string
    add_column :venue_invites, :name, :string
    add_column :venue_invites, :facebook, :string
    add_column :venue_invites, :twitter, :string
    add_column :venue_invites, :youtube, :string
    add_column :venue_invites, :vk, :string
  end
end

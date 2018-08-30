class ChangeInvites < ActiveRecord::Migration[5.1]
  def change
    drop_table :venue_invites

    rename_table :artist_invites, :invites
    add_column :invites, :invited_type, :integer
  end
end

class CreateArtistInvites < ActiveRecord::Migration[5.1]
  def change
    create_table :artist_invites do |t|
      t.string :description
      t.string :links
      t.integer :account_id

      t.timestamps
    end
  end
end

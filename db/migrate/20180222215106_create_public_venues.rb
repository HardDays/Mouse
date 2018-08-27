class CreatePublicVenues < ActiveRecord::Migration[5.1]
  def change
    create_table :public_venues do |t|
      t.string :fax
      t.string :bank_name
      t.string :account_bank_number
      t.string :account_bank_routing_number
      t.integer :num_of_bathrooms
      t.integer :min_age
      t.boolean :has_bar
      t.integer :located
      t.string :dress_code
      t.string :audio_description
      t.string :lightning_description
      t.string :stage_description
      t.integer :venue_id

      t.timestamps
    end
  end
end

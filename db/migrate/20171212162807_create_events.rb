class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :name
      t.string :tagline
      t.string :description
      t.datetime :funding_from
      t.datetime :funding_to
      t.integer :funding_goal
      t.integer :creator_id
      t.integer :artist_id
      t.integer :venue_id

      t.timestamps
    end
  end
end

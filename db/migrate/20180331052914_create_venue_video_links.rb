class CreateVenueVideoLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :venue_video_links do |t|
      t.integer :venue_id
      t.string :video_link

      t.timestamps
    end
  end
end

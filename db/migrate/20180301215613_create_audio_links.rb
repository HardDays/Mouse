class CreateAudioLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :audio_links do |t|
      t.integer :artist_id
      t.string :audio_link

      t.timestamps
    end
  end
end

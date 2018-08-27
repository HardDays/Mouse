class CreateEventGenres < ActiveRecord::Migration[5.1]
  def change
    create_table :event_genres do |t|
      t.integer :event_id
      t.integer :genre

      t.timestamps
    end
  end
end

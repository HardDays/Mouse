class CreateEventUpdates < ActiveRecord::Migration[5.1]
  def change
    create_table :event_updates do |t|
      t.integer :event_id
      t.integer :updated_by
      t.integer :action
      t.integer :field

      t.timestamps
    end
  end
end

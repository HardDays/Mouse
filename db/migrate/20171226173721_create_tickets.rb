class CreateTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :tickets do |t|
      t.string :name
      t.string :description
      t.integer :price
      t.integer :count
      t.boolean :is_special
      t.integer :event_id

      t.timestamps
    end
  end
end

class CreateFanTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :fan_tickets do |t|
      t.integer :ticket_id
      t.integer :fan_id
      t.string :code
      t.integer :price

      t.timestamps
    end
  end
end

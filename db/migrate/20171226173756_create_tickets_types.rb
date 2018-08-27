class CreateTicketsTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :tickets_types do |t|
      t.integer :name
      t.integer :ticket_id

      t.timestamps
    end
  end
end

class CreateTicketsCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :tickets_categories do |t|
      t.integer :name
      t.integer :ticket_id

      t.timestamps
    end
  end
end

class ChangeTicketsFields < ActiveRecord::Migration[5.1]
  def change
    drop_table :tickets_categories
    rename_column :tickets, :is_special, :is_for_personal_use
    add_column :tickets, :is_promotional, :boolean, default: false
  end
end

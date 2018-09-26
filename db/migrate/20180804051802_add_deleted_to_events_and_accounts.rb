class AddDeletedToEventsAndAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :is_deleted, :boolean, default: false
    add_column :accounts, :is_deleted, :boolean, default: false
  end
end

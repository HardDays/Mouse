class MovePreferences < ActiveRecord::Migration[5.1]
  def change
    remove_column :accounts, :preferred_username, :string
    remove_column :accounts, :preferred_date, :string
    remove_column :accounts, :preferred_distance, :integer, default: 0
    remove_column :accounts, :preferred_currency, :integer, default: 0
    remove_column :accounts, :preferred_time, :string

    add_column :users, :preferred_username, :string
    add_column :users, :preferred_date, :string
    add_column :users, :preferred_distance, :integer, default: 0
    add_column :users, :preferred_currency, :integer, default: 0
    add_column :users, :preferred_time, :string
  end
end

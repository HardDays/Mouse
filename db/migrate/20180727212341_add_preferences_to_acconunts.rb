class AddPreferencesToAcconunts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :preferred_username, :string
    add_column :accounts, :preferred_date, :string
    add_column :accounts, :preferred_distance, :integer, default: 1
    add_column :accounts, :preferred_currency, :integer, default: 1
    add_column :accounts, :preferred_time, :string
  end
end

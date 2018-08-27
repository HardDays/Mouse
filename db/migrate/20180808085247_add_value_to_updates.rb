class AddValueToUpdates < ActiveRecord::Migration[5.1]
  def change
    add_column :account_updates, :value, :string
    add_column :event_updates, :value, :string
  end
end

class FanTicketsRenameFanId < ActiveRecord::Migration[5.1]
  def change
    rename_column :fan_tickets, :fan_id, :account_id
  end
end

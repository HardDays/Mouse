class AddIsClosedToInboxMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :inbox_messages, :is_closed, :boolean, default: :false
  end
end

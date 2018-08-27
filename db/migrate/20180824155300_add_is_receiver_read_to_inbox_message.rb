class AddIsReceiverReadToInboxMessage < ActiveRecord::Migration[5.1]
  def change
    add_column :inbox_messages, :is_receiver_read, :boolean
  end
end

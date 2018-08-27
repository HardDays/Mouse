class ChangeInboxMessage < ActiveRecord::Migration[5.1]
  def change
    remove_column :inbox_messages, :request_msg_id, :integer
    remove_column :inbox_messages, :accept_msg_id, :integer
    remove_column :inbox_messages, :decline_msg_id, :integer
    remove_column :inbox_messages, :event_id, :integer
    add_column :inbox_messages, :sender_id, :integer

    add_column :request_messages, :inbox_message_id, :integer
    add_column :request_messages, :event_id, :integer

    add_column :accept_messages, :inbox_message_id, :integer
    add_column :accept_messages, :event_id, :integer

    add_column :decline_messages, :inbox_message_id, :integer
    add_column :decline_messages, :event_id, :integer
  end
end

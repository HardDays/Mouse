class RemoveReceiverEventFromRequestMessages < ActiveRecord::Migration[5.1]
  def change
    remove_column :request_messages, :receiver_id, :integer
    remove_column :request_messages, :event_id, :integer
  end
end

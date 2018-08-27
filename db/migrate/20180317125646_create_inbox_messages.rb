class CreateInboxMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :inbox_messages do |t|
      t.integer :receiver_id
      t.integer :event_id
      t.integer :type
      t.integer :request_msg_id
      t.integer :accept_msg_id
      t.integer :decline_msg_id

      t.timestamps
    end
  end
end

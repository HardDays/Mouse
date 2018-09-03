class CreateAdminMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_messages do |t|
      t.integer :topic_id
      t.string :message
      t.integer :sender_id
      t.integer :forwarded_from
      t.integer :forwarder_type
      t.boolean :sender_deleted, default: false
      t.boolean :receiver_deleted, default: false

      t.timestamps
    end
  end
end

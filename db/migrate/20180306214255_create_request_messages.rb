class CreateRequestMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :request_messages do |t|
      t.integer :event_id
      t.integer :receiver_id
      t.integer :time_frame
      t.boolean :is_personal, default: false
      t.integer :estimated_price
      t.string :message

      t.timestamps
    end
  end
end

class AddIsReadToInbox < ActiveRecord::Migration[5.1]
  def change
    add_column :inbox_messages, :is_read, :boolean, default: false
  end
end

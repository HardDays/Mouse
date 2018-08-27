class RenameColumnTypeAtInbox < ActiveRecord::Migration[5.1]
  def change
    rename_column :inbox_messages, :type, :message_type
  end
end

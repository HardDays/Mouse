class AddInboxMessageIdToSupportAndFeedback < ActiveRecord::Migration[5.1]
  def change
    drop_table :questions

    add_column :inbox_messages, :message_id, :integer
    rename_column :inbox_messages, :name, :subject
    rename_column :inbox_messages, :simple_message, :message


    add_column :feedbacks, :inbox_message_id, :integer
    remove_column :feedbacks, :account_id
    remove_column :feedbacks, :detail
  end
end

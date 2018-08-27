class AddTextToInboxMessage < ActiveRecord::Migration[5.1]
  def change
    add_column :inbox_messages, :simple_message, :string
  end
end

class AddNameToInboxMessage < ActiveRecord::Migration[5.1]
  def change
    add_column :inbox_messages, :name, :string
  end
end

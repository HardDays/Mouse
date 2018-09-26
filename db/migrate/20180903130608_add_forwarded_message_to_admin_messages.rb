class AddForwardedMessageToAdminMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_messages, :forwarded_message, :string
  end
end

class AddAdminIdToInboxMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :inbox_messages, :admin_id, :integer
  end
end

class AddIsReadToAdminMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_messages, :is_read, :boolean, default: false
  end
end

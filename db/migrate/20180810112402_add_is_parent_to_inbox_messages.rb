class AddIsParentToInboxMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :inbox_messages, :is_parent, :boolean, default: true
  end
end

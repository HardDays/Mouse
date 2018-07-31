class AddPurchaseItemIdFromPurchaseAttempts < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_attempts, :purchase_item_id, :integer
  end
end

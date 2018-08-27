class RemovePurchaseItemIdFromPurchaseAttempts < ActiveRecord::Migration[5.1]
  def change
    remove_column :purchase_attempts, :purchase_item_id, :integer
  end
end

class AddPurchasePaymentIdToPurchaseAttempt < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_attempts, :purchase_payment_id, :string
  end
end

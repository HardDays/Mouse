class CreatePurchaseAttempts < ActiveRecord::Migration[5.1]
  def change
    create_table :purchase_attempts do |t|
      t.integer :status
      t.integer :account_id
      t.integer :purchase_item_id
      t.integer :purchase_type
      t.string :transaction_id

      t.timestamps
    end
  end
end

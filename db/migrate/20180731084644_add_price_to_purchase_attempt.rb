class AddPriceToPurchaseAttempt < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_attempts, :price, :float
  end
end

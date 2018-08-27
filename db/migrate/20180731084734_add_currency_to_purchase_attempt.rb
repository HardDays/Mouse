class AddCurrencyToPurchaseAttempt < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_attempts, :currency, :string
  end
end

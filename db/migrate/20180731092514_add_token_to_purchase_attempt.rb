class AddTokenToPurchaseAttempt < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_attempts, :token, :string
  end
end

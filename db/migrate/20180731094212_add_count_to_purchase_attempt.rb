class AddCountToPurchaseAttempt < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_attempts, :count, :integer
  end
end

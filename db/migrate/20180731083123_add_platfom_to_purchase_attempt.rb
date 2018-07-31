class AddPlatfomToPurchaseAttempt < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_attempts, :platform, :integer
  end
end

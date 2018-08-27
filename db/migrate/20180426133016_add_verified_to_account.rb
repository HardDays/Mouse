class AddVerifiedToAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :is_verified, :boolean, default: false
  end
end

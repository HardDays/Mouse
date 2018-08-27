class AddStatusToAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :status, :integer, default: 0
  end
end

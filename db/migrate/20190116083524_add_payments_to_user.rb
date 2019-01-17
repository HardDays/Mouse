class AddPaymentsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :payment_method_id, :string
    add_column :users, :payment_method_title, :string
  end
end

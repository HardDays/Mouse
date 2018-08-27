class RemoveFields < ActiveRecord::Migration[5.1]
  def change
    remove_column :accounts, :is_verified, :boolean
    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
    remove_column :users, :image_id, :integer
    remove_column :users, :user_name, :string
    remove_column :public_venues, :price, :integer
  end
end

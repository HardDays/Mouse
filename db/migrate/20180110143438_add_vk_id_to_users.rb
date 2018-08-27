class AddVkIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :vk_id, :string
  end
end

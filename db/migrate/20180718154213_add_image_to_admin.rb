class AddImageToAdmin < ActiveRecord::Migration[5.1]
  def change
    add_column :admins, :image_id, :integer
  end
end

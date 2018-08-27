class AddImageToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :image_id, :integer
  end
end

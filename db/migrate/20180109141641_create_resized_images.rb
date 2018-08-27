class CreateResizedImages < ActiveRecord::Migration[5.1]
  def change
    create_table :resized_images do |t|
      t.string :base64
      t.integer :image_id
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end

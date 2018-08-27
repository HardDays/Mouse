class CreateImageTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :image_types do |t|
      t.integer :image_id
      t.integer :image_type
      t.string :description

      t.timestamps
    end
  end
end

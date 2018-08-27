class AddFieldsToArtist < ActiveRecord::Migration[5.1]
  def change
    add_column :artists, :price, :integer
    add_column :artists, :lat, :float
    add_column :artists, :lng, :float
  end
end

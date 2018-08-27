class AddNewFieldsToArtist < ActiveRecord::Migration[5.1]
  def change
    add_column :artists, :is_price_private, :boolean, default: true
    add_column :artists, :technical_rider, :string
    add_column :artists, :stage_rider, :string
    add_column :artists, :backstage_rider, :string
    add_column :artists, :first_name, :string
    add_column :artists, :last_name, :string
    add_column :artists, :hospitality, :string
  end
end

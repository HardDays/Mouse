class RenameColumnLightningDescriptionAtPublicVenue < ActiveRecord::Migration[5.1]
  def change
    rename_column :public_venues, :lightning_description, :lighting_description
  end
end

class AddWebsiteToVenue < ActiveRecord::Migration[5.1]
  def change
    add_column :venues, :web_site, :string
  end
end

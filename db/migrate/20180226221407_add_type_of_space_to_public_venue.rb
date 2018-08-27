class AddTypeOfSpaceToPublicVenue < ActiveRecord::Migration[5.1]
  def change
    add_column :public_venues, :type_of_space, :integer
  end
end

class AddFamilyAndFriendsToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :family_and_friends_amount, :integer
  end
end

class AddHasPrivateToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :has_private_venue, :boolean
  end
end

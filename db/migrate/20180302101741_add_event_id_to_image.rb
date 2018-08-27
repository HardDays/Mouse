class AddEventIdToImage < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :event_id, :integer
  end
end

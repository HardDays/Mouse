class RemoveColumnFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :artist_id, :integer
  end
end

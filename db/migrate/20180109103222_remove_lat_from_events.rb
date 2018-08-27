class RemoveLatFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :lat, :float
  end
end

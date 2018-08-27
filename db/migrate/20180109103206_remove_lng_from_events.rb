class RemoveLngFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :lng, :float
  end
end

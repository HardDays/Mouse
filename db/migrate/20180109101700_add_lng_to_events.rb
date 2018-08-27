class AddLngToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :lng, :float
  end
end

class AddTotalToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :total, :integer
  end
end

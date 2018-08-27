class AddDatesToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :date_from, :datetime
    add_column :events, :date_to, :datetime
  end
end

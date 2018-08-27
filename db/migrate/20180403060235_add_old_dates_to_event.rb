class AddOldDatesToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :old_date_from, :datetime
    add_column :events, :old_date_to, :datetime
  end
end

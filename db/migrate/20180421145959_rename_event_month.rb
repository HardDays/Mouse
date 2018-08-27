class RenameEventMonth < ActiveRecord::Migration[5.1]
  def change
    rename_column :events, :event_month, :event_season
  end
end

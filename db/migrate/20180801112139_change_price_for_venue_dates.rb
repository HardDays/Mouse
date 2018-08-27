class ChangePriceForVenueDates < ActiveRecord::Migration[5.1]
  def change
    change_column :venue_dates, :price_for_daytime, :float, :precision => 2
    change_column :venue_dates, :price_for_nighttime, :float, :precision => 2
  end
end

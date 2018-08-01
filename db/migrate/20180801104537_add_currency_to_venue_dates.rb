class AddCurrencyToVenueDates < ActiveRecord::Migration[5.1]
  def change
    add_column :venue_dates, :currency, :integer, default: 0
  end
end

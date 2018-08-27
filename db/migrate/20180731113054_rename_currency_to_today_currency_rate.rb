class RenameCurrencyToTodayCurrencyRate < ActiveRecord::Migration[5.1]
  def change
    rename_table :currencies, :today_corrency_rates
  end
end

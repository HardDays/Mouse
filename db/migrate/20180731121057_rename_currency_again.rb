class RenameCurrencyAgain < ActiveRecord::Migration[5.1]
  def change
    rename_table :today_corrency_rates, :today_currency_rates
  end
end

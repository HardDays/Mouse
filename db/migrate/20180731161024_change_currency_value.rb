class ChangeCurrencyValue < ActiveRecord::Migration[5.1]
  def change
    change_column :today_currency_rates, :value, :float, :precision => 4
  end
end

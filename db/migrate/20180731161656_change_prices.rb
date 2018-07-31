class ChangePrices < ActiveRecord::Migration[5.1]
  def change
    change_column :accept_messages, :price, :float, :precision => 2
    change_column :accept_messages, :travel_price, :integer, :precision => 2
    change_column :accept_messages, :hotel_price, :integer, :precision => 2
    change_column :accept_messages, :transportation_price, :integer, :precision => 2
    change_column :accept_messages, :band_price, :integer, :precision => 2
    change_column :accept_messages, :other_price, :integer, :precision => 2

    change_column :agreed_date_time_and_prices, :price, :float, :precision => 2

    change_column :artists, :price_from, :float, :precision => 2
    change_column :artists, :price_to, :float, :precision => 2
    change_column :artists, :additional_hours_price, :float, :precision => 2
    change_column :artists, :late_cancellation_fee, :float, :precision => 2

    change_column :events, :funding_goal, :float, :precision => 2
    change_column :events, :additional_cost, :float, :precision => 2

    change_column :fan_tickets, :price, :float, :precision => 2

    change_column :public_venues, :price_for_daytime, :float, :precision => 2
    change_column :public_venues, :price_for_nighttime, :float, :precision => 2

    change_column :request_messages, :estimated_price, :float, :precision => 2

    change_column :tickets, :price, :float, :precision => 2
  end
end

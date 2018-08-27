class AddCurrentCurrency < ActiveRecord::Migration[5.1]
  def change
    add_column :accept_messages, :currency, :integer, default: 0
    add_column :agreed_date_time_and_prices, :currency, :integer, default: 0
    add_column :events, :currency, :integer, default: 0
    add_column :fan_tickets, :currency, :integer, default: 0
    add_column :request_messages, :currency, :integer, default: 0
    add_column :tickets, :currency, :integer, default: 0
  end
end

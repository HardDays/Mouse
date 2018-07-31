class Ticket < ApplicationRecord
  enum currency: CurrencyHelper.all
  belongs_to :event

  has_one :tickets_type, dependent: :destroy

  has_many :fan_tickets, dependent: :nullify

  def as_json(options={})
    res = super
    res[:type] = tickets_type ? tickets_type.name : nil

    if options[:user]
      res[:original_price] = price
      res[:price] = CurrencyHelper.convert(price, currency, options[:user].preferred_currency)
    end

    return res
  end
end

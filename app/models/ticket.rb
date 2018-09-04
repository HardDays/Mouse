class Ticket < ApplicationRecord
  validates_inclusion_of :price, in: 0..10000000
  validates_inclusion_of :count, in: 1..10000000
  enum currency: CurrencyHelper.all
  belongs_to :event

  has_one :tickets_type, dependent: :destroy

  has_many :fan_tickets, dependent: :nullify

  def as_json(options={})
    res = super
    res[:type] = tickets_type ? tickets_type.name : nil

    if event.venue and event.venue.public_venue
      res[:min_age] = event.venue.public_venue.min_age
    else
      res[:min_age] = nil
    end

    if options[:user]
      res[:original_price] = price
      res[:price] = CurrencyHelper.convert(price, currency, options[:user].preferred_currency)
    end

    return res
  end
end

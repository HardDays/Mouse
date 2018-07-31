class Ticket < ApplicationRecord
  enum currency: CurrencyHelper.all
  belongs_to :event

  has_one :tickets_type, dependent: :destroy

  has_many :fan_tickets, dependent: :nullify

  def as_json(options={})
    res = super
    res[:type] = tickets_type ? tickets_type.name : nil
    return res
  end
end

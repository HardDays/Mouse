class Ticket < ApplicationRecord
  belongs_to :event

  has_one :tickets_type

  has_many :fan_tickets

  def as_json(options={})
    res = super
    res[:type] = tickets_type ? tickets_type.name : nil
    return res
  end
end

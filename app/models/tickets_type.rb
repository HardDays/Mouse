class TicketsType < ApplicationRecord
  enum name: [:in_person, :vr]

  belongs_to :ticket

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('ticket_id')
    res.delete('created_at')
    res.delete('updated_at')
    return res
  end
end

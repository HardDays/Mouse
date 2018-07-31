class FanTicket < ApplicationRecord
  enum currency: CurrencyHelper.all

  belongs_to :account
  belongs_to :ticket

  def as_json(options={})
    res = super

    if options[:with_tickets]
      res.delete('ticket_id')

      res[:ticket] = ticket
      res[:tickets_left] = nil
      if ticket
        ticket.count - FanTicket.where(ticket_id: ticket.id).count
      end
    end

    return res
  end
end

class FanTicket < ApplicationRecord
  enum currency: CurrencyHelper.all

  belongs_to :account
  belongs_to :ticket

  def as_json(options={})
    res = super

    if options[:with_tickets]
      res.delete('ticket_id')

      if options[:user]
        res[:original_price] = price
        res[:price] = CurrencyHelper.convert(price, currency, options[:user].preferred_currency)
      end

      res[:ticket] = ticket.as_json(for_fan: true, user: options[:user])
      res[:tickets_left] = nil
      if ticket
        res[:tickets_left] = ticket.count - FanTicket.where(ticket_id: ticket.id).count
      end
    end

    return res
  end
end

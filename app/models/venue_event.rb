class VenueEvent < ApplicationRecord
  enum status: StatusHelper.invites

  belongs_to :event
  belongs_to :account, foreign_key: :venue_id
  has_one :agreed_date_time_and_price, dependent: :destroy

  validates_uniqueness_of :event_id, scope: [:venue_id]

  after_initialize :set_defaults

  def set_defaults
    if self.new_record?
      if event.creator.status == "approved"
        self.status = "ready"
      else
        self.status = "pending"
      end
    end
  end

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('event_id')
    res.delete('rental_from')
    res.delete('rental_to')

    if account
      res[:venue] = account.venue.as_json(for_event: true)
      res[:approximate_price] = 0
      if account.venue.public_venue
        if event.event_time == 'evening'
          res[:approximate_price] = account.venue.public_venue.price_for_nighttime.to_i * event.event_length.to_i
        else
          res[:approximate_price] = account.venue.public_venue.price_for_daytime.to_i * event.event_length.to_i
        end

        if options[:event]
          res[:original_approximate_price] = res[:approximate_price]
          res[:approximate_price] = CurrencyHelper.convert(res[:approximate_price], account.user.preferred_currency, options[:event].currency) 
        end
      end
    end

    if ['accepted', 'owner_accepted'].include?(status) and account and account.venue.public_venue
      res[:agreement] = agreed_date_time_and_price.as_json(event: event)
    end

    if status == 'accepted'
      message = account.sent_messages.joins(:accept_message).where(accept_messages: {event: event}).first
      if message
        res['message_id'] = message.id
      end
    elsif status == 'declined'
      message = account.sent_messages.joins(:decline_message).where(decline_messages: {event: event}).first
      if message
        res['reason'] = message.decline_message.reason
        res['reason_text'] = message.decline_message.additional_text
      end
    elsif status == 'owner_declined'
      message = event.creator.sent_messages.joins(:decline_message).where(receiver_id: venue_id, decline_messages: {event: event}).first
      if message
        res['reason'] = message.decline_message.reason
        res['reason_text'] = message.decline_message.additional_text
      end
    elsif status == 'request_send'
      message = event.creator.sent_messages.joins(:request_message).where(receiver_id: venue_id, request_messages: {event: event}).first
      if message
        res['price'] = message.request_message.estimated_price
      end
    end

    return res
  end
end

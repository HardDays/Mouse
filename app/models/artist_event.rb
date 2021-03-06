class ArtistEvent < ApplicationRecord
  enum status: StatusHelper.invites

  belongs_to :event
  belongs_to :account, foreign_key: :artist_id
  has_one :agreed_date_time_and_price, dependent: :destroy

  validates_uniqueness_of :event_id, scope: [:artist_id]

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

    if options[:dates]
      res.delete("id")
      res.delete("artist_id")
      res.delete("status")
      res.delete("created_at")
      res.delete("updated_at")
      res.delete("is_active")
      res.delete("event_id")
      res[:id] = event.id
      res[:image_id] = event.image_id
      res[:date] = event.exact_date_from
      res[:name] = event.name
      res[:address] = event.address

      return res
    end

    res.delete('id')
    res.delete('event_id')

    if account
      res[:artist] = account.artist.as_json(for_event: true, event: options[:event])
      res[:approximate_price] = nil
      unless account.artist.is_hide_pricing_from_search
        res[:approximate_price] = account.artist.price_to.to_i * event.event_length.to_i
        if options[:event]
          #TODO replace account.user.... to artist.currency
          res[:original_approximate_price] = res[:approximate_price]
          res[:approximate_price] = CurrencyHelper.convert(res[:approximate_price], account.user.preferred_currency, options[:event].currency) 
        end
      end
    end

    if ['accepted', 'owner_accepted'].include?(status)
      res[:agreement] = agreed_date_time_and_price.as_json(event: event)
    end

    if event.creator
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
        message = event.creator.sent_messages.joins(:decline_message).where(receiver_id: artist_id, decline_messages: {event: event}).first
        if message
          res['reason'] = message.decline_message.reason
          res['reason_text'] = message.decline_message.additional_text
        end
      elsif status == 'request_send'
          message = event.creator.sent_messages.joins(:request_message).where(receiver_id: artist_id, request_messages: {event: event}).first
          if message
            res['price'] = message.request_message.estimated_price
          end
      end
    end

    return res
  end
end

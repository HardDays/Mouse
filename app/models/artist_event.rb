class ArtistEvent < ApplicationRecord
  enum status: StatusHelper.invites

  belongs_to :event
  belongs_to :account, foreign_key: :artist_id
  has_one :agreed_date_time_and_price

  validates_uniqueness_of :event_id, scope: [:artist_id]

  after_initialize :set_defaults

  def set_defaults
    if self.new_record?
      if event.creator.is_verified or event.creator.status == "approved"
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
      res[:date] = event.date_from

      return res
    end

    res.delete('id')
    res.delete('event_id')

    res[:artist] = account.artist.as_json(for_event: true)

    res[:approximate_price] = nil
    unless account.artist.is_hide_pricing_from_search
      res[:approximate_price] = account.artist.price_from.to_i * event.event_length.to_i
    end

    if ['owner_accepted'].include?(status)
      res[:agreement] = agreed_date_time_and_price
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
      message = event.creator.sent_messages.joins(:decline_message).where(decline_messages: {event: event}).first
      if message
        res['reason'] = message.decline_message.reason
        res['reason_text'] = message.decline_message.additional_text
        end
    elsif status == 'request_send'
        message = event.creator.sent_messages.joins(:request_message).where(request_messages: {event: event}).first
        if message
          res['price'] = message.request_message.estimated_price
        end
    end

    return res
  end
end

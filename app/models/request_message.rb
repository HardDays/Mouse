class RequestMessage < ApplicationRecord
  enum currency: CurrencyHelper.all
  enum time_frame: TimeFrameHelper.all

  belongs_to :inbox_message
  belongs_to :event
  belongs_to :artist_event, optional: true
  belongs_to :venue_event, optional: true

  after_destroy :destroy_inbox_message

  def destroy_inbox_message
    return unless inbox_message
    inbox_message.destroy unless inbox_message.destroyed?
  end

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('event_id')
    res.delete('created_at')
    res.delete('updated_at')

    if options[:user]
      res[:original_price] = estimated_price
      res[:price] = CurrencyHelper.convert(estimated_price, currency, options[:user].preferred_currency) if price != nil
    end

    res[:event_info] = event.as_json(user: options[:user])
      if expiration_date < DateTime.now
        res[:status] = 'time_expired'
      elsif expiration_date - 1.day <= DateTime.now
        res[:status] = 'expires_soon'
      else
        res[:status] = 'valid'
      end
    return res
  end
end

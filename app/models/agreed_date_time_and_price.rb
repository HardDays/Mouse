class AgreedDateTimeAndPrice < ApplicationRecord
  enum currency: CurrencyHelper.all

  belongs_to :artist_event, optional: true
  belongs_to :venue_event, optional: true

  def as_json(options={})
    attrs = super

    attrs[:original_price] = price
    if price
      if artist_event
        attrs[:price] = CurrencyHelper.convert(price, artist_event.account.user.prefered_currency, artist_event.event.currency)
      elsif venue_event
        attrs[:price] = CurrencyHelper.convert(price, venue_event.account.user.prefered_currency, venue_event.event.currency)
      end
    end
    return attrs
  end

end

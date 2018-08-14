class AgreedDateTimeAndPrice < ApplicationRecord
  enum currency: CurrencyHelper.all

  belongs_to :artist_event, optional: true
  belongs_to :venue_event, optional: true



end

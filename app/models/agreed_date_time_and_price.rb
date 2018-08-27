class AgreedDateTimeAndPrice < ApplicationRecord
  belongs_to :artist_event, optional: true
  belongs_to :venue_event, optional: true
end

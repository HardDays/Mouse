class VenueVideoLink < ApplicationRecord
  validates :video_link, presence: true

  belongs_to :venue
end

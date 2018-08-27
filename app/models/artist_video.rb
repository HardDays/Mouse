class ArtistVideo < ApplicationRecord
  validates :link, presence: true
  validates :name, presence: true

  belongs_to :artist

  validates :album_name, presence: false
end

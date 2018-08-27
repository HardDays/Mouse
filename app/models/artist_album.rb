class ArtistAlbum < ApplicationRecord
  validates :album_name, presence: true
  validates :album_artwork, presence: true
  validates :album_link, presence: true

  belongs_to :artist
end

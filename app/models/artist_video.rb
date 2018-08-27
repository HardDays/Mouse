class ArtistVideo < ApplicationRecord
  belongs_to :artist

  validates :album_name, presence: false
end

class ArtistPreferredVenue < ApplicationRecord
  enum type_of_venue: TypesOfSpaceHelper.all
  belongs_to :artist
end

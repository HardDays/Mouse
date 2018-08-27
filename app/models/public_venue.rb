class PublicVenue < ApplicationRecord
  validates_inclusion_of :min_age, in: 0..150, allow_nil: true
  validates_inclusion_of :num_of_bathrooms, in: 0..1000000, allow_nil: true

  enum type_of_space: TypesOfSpaceHelper.all
  enum located: [:indoors, :outdoors, :both]

  belongs_to :venue
  has_many :genres, foreign_key: 'venue_id', class_name: 'VenueGenre'

  def get_attrs
    attrs = {}
    attrs[:fax] = fax
    attrs[:bank_name] = bank_name
    attrs[:account_bank_number] = account_bank_number
    attrs[:account_bank_routing_number] = account_bank_routing_number
    attrs[:num_of_bathrooms] = num_of_bathrooms
    attrs[:min_age] = min_age
    attrs[:has_bar] = has_bar
    attrs[:located] = located
    attrs[:dress_code] = dress_code
    attrs[:audio_description] = audio_description
    attrs[:lighting_description] = lighting_description
    attrs[:stage_description] = stage_description
    attrs[:genres] = genres.pluck(:genre)
    attrs[:type_of_space] = type_of_space
    attrs[:country] = country
    attrs[:city] = city
    attrs[:state] = state
    attrs[:zipcode] = zipcode
    attrs[:other_address] = other_address
    attrs[:minimum_notice] = minimum_notice
    attrs[:is_flexible] = is_flexible
    attrs[:price_for_daytime] = price_for_daytime
    attrs[:price_for_nighttime] = price_for_nighttime
    attrs[:performance_time_from] = performance_time_from
    attrs[:performance_time_to] = performance_time_to
    attrs[:other_genre_description] = other_genre_description
    
    return attrs
  end
end

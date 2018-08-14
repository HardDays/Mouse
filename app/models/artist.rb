class Artist < ApplicationRecord
    # validates :first_name, presence: true
    # validates :last_name, presence: true
    validates :artist_email, presence: true
    validates :about, presence: true

    has_many :genres, foreign_key: 'artist_id', class_name: 'ArtistGenre', dependent: :destroy

    has_one :account
    has_many :audio_links, dependent: :destroy
    has_many :artist_albums, dependent: :destroy
    has_many :artist_riders, dependent: :destroy
    has_many :artist_preferred_venues, dependent: :destroy
    has_many :disable_dates, foreign_key: 'artist_id', class_name: ArtistDate, dependent: :destroy
    has_many :artist_videos, dependent: :destroy

    geocoded_by :preferred_address, latitude: :lat, longitude: :lng
    reverse_geocoded_by :lat, :lng, address: :preferred_address
    after_validation :geocode

    def as_json(options={})
        if options[:for_event]
            attrs = {}
            attrs[:first_name] = first_name
            attrs[:last_name] = last_name
            attrs[:user_name] = account.user_name
            attrs[:image_id] = account.image_id

            attrs[:is_hide_pricing_from_search] = is_hide_pricing_from_search

            #TODO replace account.user.... to artist.currency
            attrs[:price_original] = price
            attrs[:price] = CurrencyHelper.convert(price, account.user.preferred_currency, options[:event].currency) 
            return attrs
        end

        if options[:extended]
            res = super.merge(account.get_attrs)
            res[:genres] = genres.pluck(:genre)
            res[:audio_links] = audio_links
            res[:videos] = artist_videos
            res[:artist_albums] = artist_albums

            if is_hide_pricing_from_profile and not options[:my]
                res.delete('price_from')
                res.delete('price_to')
                res.delete('additional_hours_price')
            end
            res[:currency] = account.user.preferred_currency

            if options[:my]
                res[:disable_dates] = disable_dates
                res[:events_dates] = account.artist_events.joins(:event).where(
                  artist_events: {status: [ArtistEvent.statuses['owner_accepted'], ArtistEvent.statuses['active']]},
                  events: {is_active: true}
                ).as_json(dates: true)
                res[:artist_riders] = artist_riders
                res[:preferred_venues] = artist_preferred_venues
            end

            return res
        else
            attrs = account.get_attrs
            attrs[:first_name] = first_name
            attrs[:last_name] = last_name
            return attrs
        end
    end
end

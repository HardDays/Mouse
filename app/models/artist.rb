class Artist < ApplicationRecord
    # validates :first_name, presence: true
    # validates :last_name, presence: true
    validates :artist_email, presence: true
    validates :about, presence: true

    VALIDATE_FIELDS = [:artist_email, :about]

    has_many :genres, foreign_key: 'artist_id', class_name: 'ArtistGenre', dependent: :destroy

    has_one :account
    has_many :audio_links, dependent: :destroy
    has_many :artist_albums, dependent: :destroy
    has_many :artist_riders, dependent: :destroy
    has_many :artist_preferred_venues, dependent: :destroy
    has_many :disable_dates, foreign_key: 'artist_id', class_name: ArtistDate, dependent: :destroy
    has_many :artist_videos, dependent: :destroy

    geocoded_by :preferred_address do |obj, results|
        begin
            if geo = results.first
                obj.street = geo.street_address
                obj.city = geo.city
                obj.state = geo.state
                obj.country = geo.country 
                obj.zipcode = geo.postal_code
                obj.lat = geo.latitude
                obj.lng = geo.longitude
                obj.preferred_address = [obj.zipcode, obj.country, obj.state, obj.city, obj.street].collect{|c| c if c != nil and c != ''}.compact.join(', ')
            end
        rescue => exception          
        end
    end
    reverse_geocoded_by :lat, :lng do |obj, results|
        begin
            if geo = results.first
                obj.street = geo.street_address
                obj.city = geo.city
                obj.state = geo.state
                obj.country = geo.country 
                obj.zipcode = geo.postal_code
                obj.lat = geo.latitude
                obj.lng = geo.longitude
                obj.preferred_address = [obj.zipcode, obj.country, obj.state, obj.city, obj.street].collect{|c| c if c != nil and c != ''}.compact.join(', ')
            end
        rescue => exception          
        end
    end
    after_validation :geocode, :reverse_geocode

    def as_json(options={})
        if options[:for_event]
            attrs = {}
            attrs[:first_name] = first_name
            attrs[:last_name] = last_name
            attrs[:user_name] = account.user_name
            attrs[:image_id] = account.image_id

            attrs[:is_hide_pricing_from_search] = is_hide_pricing_from_search

            #TODO replace account.user.... to artist.currency
            #attrs[:price_original] = price_to
            #attrs[:price] = CurrencyHelper.convert(price_to, account.user.preferred_currency, options[:event].currency) 
            return attrs
        end

        if options[:extended]
            res = super.merge(account.get_attrs(options))
            res[:genres] = genres.pluck(:genre)
            res[:audio_links] = audio_links
            res[:videos] = artist_videos
            res[:artist_albums] = artist_albums

            if is_hide_pricing_from_profile and not options[:my]
                res.delete('price_from')
                res.delete('price_to')
                res.delete('additional_hours_price')
            elsif not is_hide_pricing_from_profile and options[:preview]
                res[:price_from_original] = price_from
                res[:price_to_original] = price_to
                res[:price_from] = CurrencyHelper.convert(price_from, account.user.preferred_currency, options[:event].currency)
                res[:price_to] = CurrencyHelper.convert(price_to, account.user.preferred_currency, options[:event].currency)
            end
            res[:currency] = account.user.preferred_currency

            if options[:my]
                res[:disable_dates] = disable_dates
                res[:events_dates] = account.artist_events.joins(:event).where(
                  artist_events: {status: [ArtistEvent.statuses['owner_accepted'], ArtistEvent.statuses['active']]},
                  events: {is_active: true, is_deleted: false}
                ).as_json(dates: true)
                res[:artist_riders] = artist_riders
                res[:preferred_venues] = artist_preferred_venues
            end

            return res
        else
            attrs = account.get_attrs(options)
            attrs[:first_name] = first_name
            attrs[:last_name] = last_name
            return attrs
        end
    end
end

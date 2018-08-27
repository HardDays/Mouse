class Venue < ApplicationRecord

    validates_inclusion_of :capacity, in: 1..1000000, allow_nil: true

    enum venue_type: [:public_venue, :private_residence]

    has_many :operating_hours, foreign_key: 'venue_id', class_name: 'VenueOperatingHour'
    has_many :office_hours, foreign_key: 'venue_id', class_name: 'VenueOfficeHour'
    has_many :dates, foreign_key: 'venue_id', class_name: 'VenueDate'
    has_many :emails, foreign_key: 'venue_id', class_name: 'VenueEmail'
    has_many :venue_video_links
    has_many :events

    has_one :account
    has_one :public_venue

    geocoded_by :address, latitude: :lat, longitude: :lng
    reverse_geocoded_by :lat, :lng, address: :address
    after_validation :geocode


    def as_json(options={})
        if options[:for_event]
            attrs = {}
            attrs[:display_name] = account.display_name
            attrs[:user_name] = account.user_name
            attrs[:image_id] = account.image_id

            attrs[:price] = nil
            return attrs
        end

        if options[:extended]
            res = super.merge(account.get_attrs)
            if public_venue
                res = res.merge(public_venue.get_attrs)
            end

            res[:video_links] = venue_video_links.pluck(:video_link)
            res[:operating_hours] = operating_hours
            res[:office_hours] = office_hours
            res[:dates] = dates
            res[:events_dates] = events.as_json(only: [:id, :date_from])
            res[:emails] = emails
            return res
        else
            return account.get_attrs
        end
    end
end

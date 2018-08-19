class Venue < ApplicationRecord
    validates :venue_type, presence: true
    #validates :address, presence: true
    validates :description, presence: true
    # validates :lat, presence: true
    # validates :lng, presence: true
    # validates :capacity, presence: true

    validates_inclusion_of :capacity, in: 1..1000000, allow_nil: true

    enum venue_type: [:public_venue, :private_residence]

    has_many :operating_hours, foreign_key: 'venue_id', class_name: 'VenueOperatingHour', dependent: :destroy
    has_many :office_hours, foreign_key: 'venue_id', class_name: 'VenueOfficeHour', dependent: :destroy
    has_many :dates, foreign_key: 'venue_id', class_name: 'VenueDate', dependent: :destroy
    has_many :emails, foreign_key: 'venue_id', class_name: 'VenueEmail', dependent: :destroy
    has_many :venue_video_links, dependent: :destroy
    has_many :events, dependent: :nullify

    has_one :account
    has_one :public_venue, dependent: :destroy

    geocoded_by :address, latitude: :lat, longitude: :lng
    reverse_geocoded_by :lat, :lng, address: :address
    after_validation :geocode
    before_validation :set_address

    def set_address
        self.address = [self.zipcode, self.country, self.state, city, self.street].collect{|c| c if c != nil and c != ''}.compact.join(', ')
    end

    def as_json(options={})
        if options[:for_event]
            attrs = {}
            attrs[:display_name] = account.display_name
            attrs[:user_name] = account.user_name
            attrs[:image_id] = account.image_id

            #attrs[:price] = nil
            return attrs
        end

        if options[:extended]
            res = super.merge(account.get_attrs(options))
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

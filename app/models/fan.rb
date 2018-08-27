class Fan < ApplicationRecord
    has_many :genres, foreign_key: 'fan_id', class_name: 'FanGenre'
    has_many :fan_tickets
    has_many :comments

    has_one :account

    geocoded_by :address, latitude: :lat, longitude: :lng
    reverse_geocoded_by :lat, :lng, address: :address
    after_validation :geocode

    def as_json(options={})
        if options[:extended]
            res = super.merge(account.get_attrs)
            res[:genres] = genres.pluck(:genre)
            return res
        else
            attrs = account.get_attrs
            attrs[:first_name] = first_name
            attrs[:last_name] = last_name
            return attrs
        end
    end
end

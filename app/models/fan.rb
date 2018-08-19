class Fan < ApplicationRecord
    validates :first_name, presence: true
    validates :last_name, presence: true

    has_many :genres, foreign_key: 'fan_id', class_name: 'FanGenre', dependent: :destroy

    has_one :account

    geocoded_by :address do |obj, results|
        begin
            if geo = results.first
                obj.street = geo.street_address
                obj.city = geo.city
                obj.state = geo.state
                obj.country = geo.country 
                obj.zipcode = geo.postal_code
                obj.lat = geo.latitude
                obj.lng = geo.longitude
                obj.address = [obj.zipcode, obj.country, obj.state, obj.city, obj.street].collect{|c| c if c != nil and c != ''}.compact.join(', ')
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
                obj.address = [obj.zipcode, obj.country, obj.state, obj.city, obj.street].collect{|c| c if c != nil and c != ''}.compact.join(', ')
            end
        rescue => exception          
        end
    end
    after_validation :geocode, :reverse_geocode

    def as_json(options={})
        if options[:extended]
            res = super.merge(account.get_attrs(options))
            res[:genres] = genres.pluck(:genre)
            return res
        else
            attrs = account.get_attrs(options)
            attrs[:first_name] = first_name
            attrs[:last_name] = last_name
            return attrs
        end
    end
end

class VenueEmail < ApplicationRecord
    validates :name, presence: true
    validates :email, presence: true

    belongs_to :venue
    def as_json(options={})
        res = super
        res.delete('id')
        res.delete('venue_id')
        res.delete('created_at')
        res.delete('updated_at')
        return res
    end
end

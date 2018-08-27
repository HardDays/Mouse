class VenueOfficeHour < ApplicationRecord
    validates :day, presence: true
    validates :begin_time, presence: true
    validates :end_time, presence: true
    belongs_to :venue

    enum day: [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday], _prefix: true

    def as_json(options={})
        res = super
        res.delete('id')
        res.delete('venue_id')
        res.delete('created_at')
        res.delete('updated_at')
        return res
    end
end

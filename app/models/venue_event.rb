class VenueEvent < ApplicationRecord
  enum status: StatusHelper.all

  belongs_to :event
  belongs_to :account, foreign_key: :venue_id

  validates_uniqueness_of :event_id, scope: [:venue_id]

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('event_id')

    return res
  end
end

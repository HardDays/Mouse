class ArtistDate < ApplicationRecord
  belongs_to :artist

  validates_uniqueness_of :date, scope: [:artist_id]

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('artist_id')
    res.delete('created_at')
    res.delete('updated_at')

    return res
  end
end

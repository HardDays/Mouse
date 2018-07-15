class ArtistDate < ApplicationRecord
  belongs_to :artist

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('artist_id')
    res.delete('created_at')
    res.delete('updated_at')

    return res
  end
end

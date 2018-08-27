class ArtistRider < ApplicationRecord
  validates :rider_type, presence: true
  enum rider_type: [:stage, :backstage, :hospitality, :technical]

  belongs_to :artist

  def as_json(options={})
    res = super

    res[:artist_id] = artist.account.id
    if not options[:file_info]
        res.delete('uploaded_file_base64')
    end
    return res
  end

end

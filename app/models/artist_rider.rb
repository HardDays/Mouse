class ArtistRider < ApplicationRecord
  enum rider_type: [:stage, :backstage, :hospitality, :technical]

  belongs_to :artist

  #has_attached_file :uploaded_file
  #validates_attachment :uploaded_file, presence: true

  def as_json(options={})
    res = super

    res[:artist_id] = artist.account_id
    if not options[:file_info]
        res.delete('uploaded_file_base64')
    end
    return res
  end

end

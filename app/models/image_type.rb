class ImageType < ApplicationRecord
  enum image_type: [:outside_venue, :stage, :seating, :bar, :audience, :dressing_room, :other]
  validates :image_type, presence: true

  belongs_to :image, optional: true

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('image_id')
    res.delete('created_at')
    res.delete('updated_at')
    return res
  end
end

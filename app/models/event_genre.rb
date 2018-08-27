class EventGenre < ApplicationRecord
  enum genre: GenresHelper.all

  belongs_to :event

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('event_id')
    res.delete('created_at')
    res.delete('updated_at')
    return res
  end
end

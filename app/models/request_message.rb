class RequestMessage < ApplicationRecord
  enum time_frame: TimeFrameHelper.all

  belongs_to :inbox_message, dependent: :destroy
  belongs_to :event
  belongs_to :artist_event, optional: true
  belongs_to :venue_event, optional: true

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('event_id')
    res.delete('created_at')
    res.delete('updated_at')

    res[:event_info] = event
    if expiration_date != nil
      if expiration_date < DateTime.now
        res[:status] = 'time_expired'
      elsif expiration_date - 1.day <= DateTime.now
        res[:status] = 'expires_soon'
      else
        res[:status] = 'valid'
      end 
    else
      res[:status] = 'valid'
    end
    return res
  end
end

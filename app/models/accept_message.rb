class AcceptMessage < ApplicationRecord
  belongs_to :inbox_message, dependent: :destroy
  belongs_to :event

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('event_id')

    res[:event_info] = event
    return res
  end
end

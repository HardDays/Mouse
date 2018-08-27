class InboxMessage < ApplicationRecord
  belongs_to :receiver, foreign_key: 'receiver_id', class_name: 'Account'
  belongs_to :sender, foreign_key: 'sender_id', class_name: 'Account', optional: true
  belongs_to :admin, optional: true

  enum message_type: [:accept, :request, :decline, :blank]
  has_one :decline_message
  has_one :accept_message
  has_one :request_message

  def as_json(options = {})
    res = super
    res.delete('event_id')
    res.delete('admin_id')
    res.delete('updated_at')
    res.delete('request_msg_id')
    res.delete('accept_msg_id')
    res.delete('decline_msg_id')

    if admin
      res[:sender] = admin.as_json(for_message: true)
    else
      res[:sender] = sender.as_json(for_message: true)
    end

    if request_message
      res[:message_info] = request_message
    elsif accept_message
      res[:message_info] = accept_message
    elsif decline_message
      res[:message_info] = decline_message
    end

    return res
  end
end

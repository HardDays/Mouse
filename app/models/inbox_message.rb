class InboxMessage < ApplicationRecord
  belongs_to :receiver, foreign_key: 'receiver_id', class_name: 'Account', optional: true
  belongs_to :sender, foreign_key: 'sender_id', class_name: 'Account', optional: true
  belongs_to :admin, optional: true
  belongs_to :reply, foreign_key: 'message_id', class_name: 'InboxMessage', optional: true

  enum message_type: [:accept, :request, :decline, :blank, :support, :feedback]

  has_one :decline_message, dependent: :destroy
  has_one :accept_message, dependent: :destroy
  has_one :request_message, dependent: :destroy
  has_one :feedback_message, foreign_key: 'inbox_message_id', class_name: 'Feedback', dependent: :destroy

  before_create :set_default

  def set_default
    self.is_receiver_read = false
  end

  def get_ancestor
    if self.reply
      return [self.reply] + self.reply.get_ancestor
    else
      return []
    end
  end

  def as_json(options = {})
    if options[:for_request]
      attrs = {}
      attrs[:preferred_date_from] = accept_message.preferred_date_from
      attrs[:preferred_date_to] = accept_message.preferred_date_to
      attrs[:price] = accept_message.price
      attrs[:currency] = accept_message.currency

      return attrs
    end

    res = super
    res.delete('admin_id')
    res.delete('updated_at')
    res.delete('message_id')
    res.delete('is_closed')

    if options[:extended]
      res[:reply] = get_ancestor
    end

    if options[:admin]
      res[:is_closed] = is_closed
    end

    if admin
      res[:sender] = admin.as_json(for_message: true)
    else
      res[:sender] = sender.as_json(for_message: true)
    end

    if request_message
      res[:message_info] = request_message.as_json(user: options[:user])
    elsif accept_message
      res[:message_info] = accept_message.as_json(user: options[:user])
    elsif decline_message
      res[:message_info] = decline_message.as_json(user: options[:user])
    elsif feedback_message
      res[:rate_score] = feedback_message.rate_score
      res[:message_info] = feedback_message.as_json(user: options[:user])
    end

    return res
  end
end

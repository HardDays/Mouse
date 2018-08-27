class DeclineMessage < ApplicationRecord
  enum reason: [:price, :location, :time, :other]

  belongs_to :inbox_message, dependent: :destroy
  belongs_to :event

  after_destroy :destroy_inbox_message

  def destroy_inbox_message
    return unless inbox_message
    inbox_message.destroy unless inbox_message.destroyed?
  end

  def as_json(options={})
    res = super
    res.delete('id')
    res.delete('event_id')

    res[:event_info] = event.as_json(user: options[:user])
    return res
  end
end

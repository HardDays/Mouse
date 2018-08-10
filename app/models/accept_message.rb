class AcceptMessage < ApplicationRecord
  enum currency: CurrencyHelper.all

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

    res[:event_info] = event
    return res
  end
end

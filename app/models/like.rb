class Like < ApplicationRecord
  belongs_to :user
  belongs_to :account
  belongs_to :event

  validates_uniqueness_of :user_id, :scope => [:event_id]

  def as_json(options={})
    res = super
    res.delete('user_id')
    res.delete('event_id')
    res.delete('account_id')
    res.delete('updated_at')
    res.delete('id')

    if options[:feed]
      res[:event] = event.as_json(only: [:id, :name])
    end
    res[:account] = account.as_json(only: [:id, :user_name, :image_id, :display_name])
    return res
  end
end

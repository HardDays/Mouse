class Like < ApplicationRecord
  belongs_to :user
  belongs_to :account
  belongs_to :feed_item

  validates_uniqueness_of :user_id, :scope => [:feed_item_id]

  def as_json(options={})
    res = super
    res.delete('user_id')
    res.delete('event_id')
    res.delete('account_id')
    res.delete('updated_at')
    res.delete('id')

    res[:account] = nil
    if account
      account.as_json(only: [:id, :user_name, :image_id, :display_name])
    end
    return res
  end
end

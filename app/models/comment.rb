class Comment < ApplicationRecord
  validates :text, presence: true

  belongs_to :event
  belongs_to :account, foreign_key: 'fan_id'

  def as_json(options={})
    res = super
    res.delete('account_id')

    res[:account] = nil
    if account
      res[:account] = account.as_json(for_message: true)
    end

    return res
  end
end

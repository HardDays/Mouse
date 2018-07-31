class Comment < ApplicationRecord
  validates :text, presence: true

  belongs_to :feed_item
  belongs_to :account

  def as_json(options={})
    res = super
    res.delete('account_id')

    res[:account] = nil
    if account
      res[:account] = account.as_json(only: [:id, :user_name, :image_id, :display_name])
    end

    return res
  end
end

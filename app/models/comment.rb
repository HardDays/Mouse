class Comment < ApplicationRecord
  belongs_to :event
  belongs_to :account

  def as_json(options={})
    res = super
    res.delete('account_id')

    res[:account] = account.as_json(only: [:id, :user_name, :image_id, :display_name])

    return res
  end
end

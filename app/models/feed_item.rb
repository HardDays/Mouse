class FeedItem < ApplicationRecord
  belongs_to :event_update, optional: true
  belongs_to :account_update, optional: true

  has_many :comments
  has_many :likes

  def aj_json(options={})
    res = super
    res.delete("event_update_id")
    res.delete("account_update_id")

    if event_update
      res[:event] = event.as_json(only: [:id, :name])
      res[:account] = event.creator.as_json(:only => [:id, :user_name, :image_id])
      res[:likes] = event.likes.count
      res[:is_liked] = event.likes.where(user_id: options[:user].id).exists?
    end

    return res
  end
end

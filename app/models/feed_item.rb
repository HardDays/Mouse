class FeedItem < ApplicationRecord
  belongs_to :event_update, optional: true
  belongs_to :account_update, optional: true

  has_many :comments
  has_many :likes

  def as_json(options={})
    res = super
    res.delete("event_update_id")
    res.delete("account_update_id")

    res[:comments] = comments.count
    res[:likes] = likes.count
    res[:is_liked] = likes.where(user_id: options[:user].id).exists?

    if event_update
      res[:type] = "event update"
      res[:action] = "#{event_update.action} #{event_update.field}"
      res[:event] = event_update.event.as_json(only: [:id, :name])
      res[:account] = event_update.event.creator.as_json(:only => [:id, :user_name, :image_id])
    elsif account_update
      res[:type] = "account update"
      res[:action] = "#{account_update.action} #{account_update.field}"
      res[:account] = account_update.account
    end

    return res
  end
end

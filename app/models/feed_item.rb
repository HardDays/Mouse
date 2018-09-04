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
      res[:type] = "event_update"
      res[:action] = [event_update.action, event_update.field].compact.join("_")
      res[:event] = event_update.event.as_json(only: [:id, :name, :comments_available])
      res[:account] = event_update.event.creator.as_json(:only => [:id, :user_name, :image_id])

      if event_update.action == 'add_ticket'
        res[:ticket] = event_update.event.tickets.where(id: event_update.value.to_i)
      else
        res[:value] = event_update.value
      end
    elsif account_update
      res[:type] = "account_update"
      res[:action] = [account_update.action, account_update.field].compact.join("_")
      res[:account] = account_update.account
      res[:value] = account_update.value
    end

    return res
  end
end

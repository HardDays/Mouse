class FeedItem < ApplicationRecord
  enum action: HistoryHelper::ACTIONS, _suffix: true
  enum field: HistoryHelper::FIELDS, _suffix: true

  belongs_to :account, optional: true
  belongs_to :event, optional: true

  has_many :feed_comments
  has_many :likes

  def as_json(options={})
    res = super

    if options[:only]
      return super(options)
    end

    res[:comments] = feed_comments.count
    res[:likes] = likes.count
    if options[:user]
      res[:is_liked] = likes.where(user_id: options[:user].id).exists?
    end

    if event
      res[:type] = "event_update"
      res[:action] = [action, field].compact.join("_")
      res[:event] = event.as_json(only: [:id, :name, :comments_available])
      res[:account] = event.creator.as_json(:only => [:id, :user_name, :image_id])

      if action == 'add_ticket'
        res[:ticket] = event.tickets.where(id: value.to_i)
      else
        res[:value] = value
      end
    elsif account
      res[:type] = "account_update"
      res[:action] = [action, field].compact.join("_")
      res[:account] = account
      res[:value] = value
    end

    return res
  end
end

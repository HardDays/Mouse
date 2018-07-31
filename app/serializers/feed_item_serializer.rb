class FeedItemSerializer < ActiveModel::Serializer
  attributes :id, :event, :account, :likes, :comments, :type, :action

  def comments
    object.comments.count
  end

  def likes
    object.likes.count
  end

  def event
    if object.event_update
      return object.event_update.event.as_json(only: [:id, :name])
    end
  end

  def account
    if object.event_update
      return object.event_update.event.creator.as_json(:only => [:id, :user_name, :image_id])
    end
  end

  def type
    if object.event_update
      return "event update"
    elsif object.account_update
      return "account update"
    end
  end

  def action
    if object.event_update
      return "#{object.event_update.action} #{object.event_update.field}"
    elsif object.account_update
      return "#{object.account_update.action} #{object.account_update.field}"
    end
  end

    # res[:is_liked] = event.likes.where(user_id: options[:user].id).exists?

end
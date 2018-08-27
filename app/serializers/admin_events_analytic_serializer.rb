class AdminEventsAnalyticSerializer < ActiveModel::Serializer
  attributes :name, :date_from, :is_crowdfunding_event, :comments, :likes, :views, :status

  def comments
    object.comments.count
  end

  def likes
    object.likes.count
  end
end
class AdminNotificationsChannel < ApplicationCable::Channel

  def subscribed
    stream_for user_id

    admin = Admin.where(user_id: user_id)
    feed = AdminFeed.last
    if admin and last
      has_new = !AdminSeenFeed.where(admin_id: admin.id, admin_feed_id: feed.id).exists?
      AdminNotificationsChannel.broadcast_to(user_id, has_new: has_new)
    end
  end

end
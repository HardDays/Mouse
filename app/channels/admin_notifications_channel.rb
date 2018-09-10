class AdminNotificationsChannel

  def subscribed
    stream_for user_id

    # admin = Admin.where(user_id: user_id)
    # if admin
    #   has_new = AdminFeed.where("created_at >= :date", {:date => admin.last_login})
    #   ApplicationCable::AdminNotificationsChannel.broadcast_to(user_id, count: count)
    # end
  end

end
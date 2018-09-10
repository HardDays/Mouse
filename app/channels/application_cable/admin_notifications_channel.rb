class AdminNotificationsChannel

  def subscribed
    stream_for user_id
  end

end
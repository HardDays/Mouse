class AdminMessagesChannel < ApplicationCable::Channel

  def subscribed
    stream_for admin_id

    count = AdminTopic.where(sender_id: user_id).messages.where(is_read: false).where.not(sender_id: user_id).count +
      AdminTopic.where(receiver_id: user_id).messages.where(is_read: false).where.not(sender_id: user_id).count
    AdminMessagesChannel.broadcast_to(user_id, count: count)
  end

end


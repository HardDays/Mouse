class AdminMessagesChannel < ApplicationCable::Channel

  def subscribed
    stream_for user_id
  end

  def received(data)
    if data == "count"
      count = AdminMessage.where(is_read: false).where.not(sender_id: user_id).count
      AdminMessagesChannel.broadcast_to(user_id, count: count)
    end
  end
end


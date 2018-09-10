class AdminMessagesChannel < ApplicationCable::Channel

  def subscribed
    stream_for user_id

    count = AdminMessage.where(receiver_id: user_id, is_read: false)
    AdminMessagesChannel.broadcast_to(user_id, count: count)
  end

  def receive(data)
    if data.value == "count"

      count = AdminMessage.where(receiver_id: user_id, is_read: false)
      AdminMessagesChannel.broadcast_to(user_id, count: count)
    end
  end
end
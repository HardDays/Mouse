class AdminMessagesChannel < ApplicationCable::Channel

  def subscribed
    stream_for user_id
  end

  def receive(data)
    if data.value == "count"
      count = AdminMessage.where(receiver_id: data.user_id, is_read: false)
      AdminMessagesChannel.broadcast_to(data.user_id, count: count)
    end
  end
end
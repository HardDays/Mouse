module ApplicationCable
  class AdminMessagesChannel < ApplicationCable::Channel

    def subscribed
      stream_for user_id

      count = AdminMessage.where(is_read: false).where.not(sender_id: user_id).count
      ApplicationCable::AdminMessagesChannel.broadcast_to(user_id, count: count)
    end
  end
end

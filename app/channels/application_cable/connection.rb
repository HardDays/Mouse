module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user_id

    def connect
      token = Token.find_by(token: request.params[:token])
      if token
        self.user_id = token.user.id
      end
    end
  end
end

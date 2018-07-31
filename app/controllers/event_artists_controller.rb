class EventArtistsController < ApplicationController
  before_action :set_event, only: [:create, :destroy, :owner_accept, :owner_decline, :artist_accept, :artist_decline,
                                   :artist_set_active, :artist_remove_active, :send_request, :resend_message]
  before_action :set_message, only: [:owner_accept, :owner_decline, :artist_accept, :artist_decline]
  before_action :authorize_creator, only: [:create, :destroy, :owner_accept, :owner_decline,
                                           :artist_set_active, :artist_remove_active, :send_request, :resend_message]
  before_action :authorize_artist, only: [:artist_accept, :artist_decline]
  swagger_controller :event_artists, "Event artists"

  # POST /events/1/artist
  swagger_api :create do
    summary "Add artist to event"
    param :path, :event_id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :form, :artist_id, :integer, :required, "Artist account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :not_found
  end
  def create
    if artist_available?
      @event.artists << @artist_acc
      @event.save

      render status: :ok
    else
      render status: :unprocessable_entity
    end
  end

  # POST /events/1/artist/1/send_request
  swagger_api :send_request do
    summary "Send request to the artist"
    param :path, :event_id, :integer, :required, "Event id"
    param :path, :id, :integer, :required, "Artist account id"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param_list :form, :time_frame_range, :integer, :required, "Time frame to answer range", ["hour", "day", "week", "month"]
    param :form, :time_frame_number, :integer, :required, "Time frame to answer"
    param :form, :is_personal, :boolean, :optional, "Is message personal"
    param :form, :estimated_price, :integer, :optional, "Estimated price to perform"
    param :form, :currency, :integer, :required, "Preferred currency format", [:RUB, :USD, :EUR]
    param :form, :message, :string, :optional, "Additional text"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :not_found
  end
  def send_request
    params[:artist_id] = params[:id]
    if artist_available?
      @artist_event = @event.artist_events.find_by(artist_id: params[:id])

      if @artist_event and ["ready", "declined", "owner_declined"].include?(@artist_event.status)
        artist_acc = Account.find(params[:id])

        if artist_acc
          @artist_event.status = 'request_send'
          send_mouse_request(artist_acc)
          @artist_event.save

          render status: :ok
        else
          render status: :not_found
        end
      else
        render status: :unprocessable_entity
      end
    else
      render status: :unprocessable_entity
    end
  end

  # POST /events/1/artist/1/owner_accept
  swagger_api :owner_accept do
    summary "Accept artist for event"
    param :path, :event_id, :integer, :required, "Event id"
    param :path, :id, :integer, :required, "Artist account id"
    param :form, :message_id, :integer, :required, "Inbox message id"
    param :form, :datetime_from, :datetime, :required, "Date and time of performance"
    param :form, :datetime_to, :datetime, :required, "Date and time of performance"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :not_found
  end
  def owner_accept
    @artist_event = @event.artist_events.find_by(artist_id: params[:id])

    if @event.artist_events.where(status: 'owner_accepted').count >= @event.artists_number
      render json: {errors: "Full event"}, status: :unprocessable_entity and return
    end
    #TODO: check here pls
    #if @message.is_read
    #  render status: :unprocessable_entity and return
    #end

    if @artist_event and ["accepted"].include?(@artist_event.status) and number_valid?
      if date_valid?
        read_message
        @artist_event.status = 'owner_accepted'

        change_event_date
        send_accept_message(@artist_event.account)
        @artist_event.save

        render status: :ok
      else
        render json: {errors: "Invalid date"}, status: :unprocessable_entity
      end
    else
      render status: :not_found
    end
  end

  # POST /events/1/artist/1/owner_decline
  swagger_api :owner_decline do
    summary "Remove artist from event"
    param :path, :event_id, :integer, :required, "Event id"
    param :path, :id, :integer, :required, "Artist account id"
    param_list :form, :reason, :string, :required, "Reason", ["price", "location", "time", "other"]
    param :form, :message_id, :integer, :optional, "Inbox message id"
    param :form, :additional_text, :string, :optional, "Message"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :not_found
  end
  def owner_decline
    @artist_event = @event.artist_events.find_by(artist_id: params[:id])

    #TODO: check here pls
    #if params[:message_id] and @message.is_read
    #  render status: :unprocessable_entity and return
    #end

    if @artist_event and not ["decline"].include?(@artist_event.status)
      if params[:message_id]
        read_message
      end

      if @artist_event.status == 'owner_accepted'
        undo_change_event_date
      end

      @artist_event.status = 'owner_declined'
      send_owner_decline(@artist_event.account)
      @artist_event.save

      render status: :ok
    else
      render status: :not_found
    end
  end

  # POST /events/1/artist/1/artist_accept
  swagger_api :artist_accept do
    summary "Artist accepts request"
    param :path, :id, :integer, :required, "Artist id"
    param :path, :event_id, :integer, :required, "Event id"
    param :form, :preferred_date_from, :datetime, :required, "Preferred date from"
    param :form, :preferred_date_to, :datetime, :required, "Preferred date to"
    param :form, :price, :integer, :required, "Price"
    param :form, :travel_price, :integer, :optional, "Travel price"
    param :form, :hotel_price, :integer, :optional, "Hotel price"
    param :form, :transportation_price, :integer, :optional, "Transportation price"
    param :form, :band_price, :integer, :optional, "Band price"
    param :form, :other_price, :integer, :optional, "Other price"
    param :form, :currency, :integer, :required, "Preferred currency format", [:RUB, :USD, :EUR]
    param :form, :message_id, :integer, :required, "Inbox message id"
    param :header, 'Authorization', :string, :required, "Artist auth key"
    response :not_found
    response :unauthorized
  end
  def artist_accept
    @artist_acc = Account.find(params[:id])
    @artist_event = @event.artist_events.find_by(artist_id: @artist_acc.id)

    if @message.is_read
      render status: :unprocessable_entity and return
    end

    if @artist_event and ["request_send"].include?(@artist_event.status)
      read_message
      @artist_event.status = 'accepted'
      send_approval(@artist_acc)
      set_agreement
      @artist_event.save

      render status: :ok
    else
      render status: :not_found
    end
  end

  # POST /events/1/artist/1/artist_decline
  swagger_api :artist_decline do
    summary "Artist declines request"
    param :path, :id, :integer, :required, "Artist id"
    param :path, :event_id, :integer, :required, "Event id"
    param_list :form, :reason, :string, :required, "Reason", ["price", "location", "time", "other"]
    param :form, :message_id, :integer, :required, "Inbox message id"
    param :form, :additional_text, :string, :optional, "Message"
    param :header, 'Authorization', :string, :required, "Artist auth key"
    response :not_found
    response :unauthorized
  end
  def artist_decline
    @artist_acc = Account.find(params[:id])
    @artist_event = @event.artist_events.find_by(artist_id: @artist_acc.id)

    if @message.is_read
      render status: :unprocessable_entity and return
    end

    if @artist_event and ["request_send"].include?(@artist_event.status)
      read_message
      @artist_event.status = 'declined'
      send_decline(@artist_acc)
      @artist_event.save

      render status: :ok
    else
      render status: :not_found
    end
  end

  # POST /events/1/artist/1/resend_message
  swagger_api :resend_message do
    summary "Resend message"
    param :path, :event_id, :integer, :required, "Event id"
    param :path, :id, :integer, :required, "Artist account id"
    param_list :form, :time_frame_range, :integer, :required, "Time frame to answer range", ["hour", "day", "week", "month"]
    param :form, :time_frame_number, :integer, :required, "Time frame to answer"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :not_found
  end
  def resend_message
      event_artist = ArtistEvent.find_by(artist_id: params[:id], event_id: params[:event_id])

      if !event_artist
        render status: :not_found and return
      end

      message = InboxMessage.joins(:request_message).where(
        sender_id: params[:account_id],
        receiver_id: params[:id],
        request_messages: {event_id: params[:event_id]}
      ).order("inbox_messages.created_at DESC").first

      if message
        new_message = message.dup
        new_message.is_read = false
        new_message.request_message = message.request_message.dup
        new_message.request_message.time_frame_range = params[:time_frame_range]
        new_message.request_message.time_frame_number = params[:time_frame_number]
        new_message.expiration_date = Time.now + TimeFrameHelper.to_seconds(params[:time_frame_range]).to_i * params[:time_frame_number].to_i

        if new_message.save!
          event_artist.status = 'request_send'
          event_artist.save

          render status: :ok
        else
          render json: @account.errors, status: :unprocessable_entity
        end
      else
        render status: :unprocessable_entity
      end
  end

  # POST /events/1/artist/1/set_active
  swagger_api :artist_set_active do
    summary "Set artist active"
    param :path, :id, :integer, :required, "Artist id"
    param :path, :event_id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Event owner id"
    param :header, 'Authorization', :string, :required, "Event owner auth key"
    response :not_found
    response :unprocessable_entity
    response :unauthorized
  end
  def artist_set_active
    @artist_acc = Account.find(params[:id])
    @artist_event = @event.artist_events.find_by(artist_id: @artist_acc.id)

    if @artist_event
      @artist_event.is_active = true
      @artist_event.save!

      render status: :ok
    else
      render status: :not_found
    end
  end

  # POST /events/1/artist/1/remove_active
  swagger_api :artist_remove_active do
    summary "Remove active artist"
    param :path, :id, :integer, :required, "Artist id"
    param :path, :event_id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Event owner id"
    param :header, 'Authorization', :string, :required, "Event owner auth key"
    response :not_found
    response :unauthorized
  end
  def artist_remove_active
    @artist_acc = Account.find(params[:id])
    @artist_event = @event.artist_events.find_by(artist_id: @artist_acc.id)

    if @artist_event
        @artist_event.is_active = false
        @artist_event.save!

      render status: :ok
    else
      render status: :not_found
    end
  end

  # DELETE /events/1/artist/1
  swagger_api :destroy do
    summary "Remove artist from event"
    param :path, :id, :integer, :required, "Artist id"
    param :path, :event_id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Event owner id"
    param :header, 'Authorization', :string, :required, "Event owner auth key"
    response :not_found
    response :forbidden
    response :unauthorized
  end
  def destroy
    @artist_acc = Account.find(params[:id])
    @artist_event = @event.artist_events.find_by(artist_id: @artist_acc.id)

    if @artist_event
      if ['ready', 'pending'].include?(@artist_event.status)
        @artist_event.destroy
        render status: :ok
      elsif @artist_event.status == 'request_send'
        message = InboxMessage.joins(:request_message).find_by(
          request_messages: {event_id: @artist_event.event.id},
          sender_id: @artist_event.event.creator_id)
        if message
             message.destroy
        end

        @artist_event.status = 'ready'
        @artist_event.save

        render status: :ok
      else
        render status: :forbidden
      end
    else
      render status: :not_found
    end
  end

  private
    def set_event
      @event = Event.find(params[:event_id])
    end

    def set_message
      if params[:message_id]
        @message = InboxMessage.find(params[:message_id])
      end
    end

    def authorize_creator
      @user = AuthorizeHelper.authorize(request)
      @account = Account.find(params[:account_id])
      render status: :unauthorized and return if @user == nil or @account.user != @user

      @creator = Event.find(params[:event_id]).creator
      render status: :unauthorized if @creator != @account or @creator.user != @user
    end

    def authorize_artist
      @user = AuthorizeHelper.authorize(request)
      @account = Account.find(params[:id])
      render status: :unauthorized and return if @user == nil or @account.user != @user or @account.account_type != 'artist'
    end

    def send_mouse_request(account)
      request_message = RequestMessage.new(request_message_params)
      request_message.expiration_date = Time.now + TimeFrameHelper.to_seconds(params[:time_frame_range]).to_i * params[:time_frame_number].to_i
      request_message.save

      inbox_message = InboxMessage.new(name: "#{@event.name} request", message_type: "request")
      inbox_message.request_message = request_message

      @event.request_messages << request_message
      @creator.sent_messages << inbox_message
      account.inbox_messages << inbox_message
      inbox_message.save
    end

    def send_approval(account)
      @accept_message = AcceptMessage.new(accept_message_params)
      @accept_message.save

      inbox_message = InboxMessage.new(name: "#{account.user_name} accepted #{@event.name} invitation", message_type: "accept")
      inbox_message.accept_message = @accept_message

      @event.accept_messages << @accept_message
      @event.creator.inbox_messages << inbox_message
      account.sent_messages << inbox_message
    end

    def send_decline(account)
      decline_message = DeclineMessage.new(decline_message_params)
      decline_message.save

      inbox_message = InboxMessage.new(name: "#{account.user_name} declined #{@event.name} invitation", message_type: "decline")
      inbox_message.decline_message = decline_message

      @event.decline_messages << decline_message
      @event.creator.inbox_messages << inbox_message
      account.sent_messages << inbox_message
    end

    def send_owner_decline(account)
      decline_message = DeclineMessage.new(decline_message_params)
      decline_message.save

      inbox_message = InboxMessage.new(name: "#{@event.name} owner reply", message_type: "decline")
      inbox_message.decline_message = decline_message

      @event.decline_messages << decline_message
      account.inbox_messages << inbox_message
      @event.creator.sent_messages << inbox_message
    end

    def send_accept_message(account)
      inbox_message = InboxMessage.new(
        name: "#{@event.name} owner reply",
        message_type: "blank",
        simple_message: "#{@event.name} owner accepted your conteroffer."
      )

      @event.creator.sent_messages << inbox_message
      account.inbox_messages << inbox_message
    end

    def set_agreement
      agreement = AgreedDateTimeAndPrice.new
      agreement.datetime_from = params[:preferred_date_from]
      agreement.datetime_to = params[:preferred_date_to]
      agreement.price = params[:price]
      agreement.currency = params[:currency]
      agreement.artist_event = @artist_event
      agreement.save!
    end

    def read_message
      @message.is_read = true
      @message.save
    end

    def artist_available?
      @artist_acc = Account.find(params[:artist_id])
      if @artist_acc and @artist_acc.account_type == 'artist'
        return true
      end

      return false
    end

    def number_valid?
      return @event.artist_events.where(status: 'owner_accepted').count < @event.artists_number
    end

    def date_valid?
      if @event.date_from.nil?
        return true
      end

      agreed_date = @artist_event.agreed_date_time_and_price
      if @event.date_from <= agreed_date.datetime_from and @event.date_to >= agreed_date.datetime_to
        return true
      end
      return false
    end

    def change_event_date
      @event.old_date_from = @event.date_from
      @event.old_date_to = @event.date_to
      @event.date_from = @artist_event.agreed_date_time_and_price.datetime_from
      @event.date_to = @artist_event.agreed_date_time_and_price.datetime_to
      @event.save!
    end

    def undo_change_event_date
      @event.date_from = @event.old_date_from
      @event.date_to = @event.old_date_to
      @event.old_date_from = nil
      @event.old_date_to = nil
      @event.save!
    end

    def request_message_params
      params.permit(:time_frame_range, :time_frame_number, :is_personal, :estimated_price, :currency, :message)
    end

    def accept_message_params
      params.permit(:preferred_date_from, :preferred_date_to, :price, :currency,
                    :travel_price, :hotel_price, :transportation_price, :band_price, :other_price)
    end

    def decline_message_params
      params.permit(:reason, :additional_text)
    end

    def agreement_params
      params.permit(:datetime_from, :datetime_to)
    end

end
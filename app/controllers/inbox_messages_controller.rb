class InboxMessagesController < ApplicationController
  before_action :authorize_account
  before_action :set_message, only: [:show, :destroy, :change_responce_time]
  swagger_controller :inbox_messages, "Inbox messages"

  # GET account/1/inbox_messages
  swagger_api :index do
    summary "Retrieve list of inbox messages"
    param :path, :account_id, :integer, :required, "Authorized account id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def index
    top_messages = @account.inbox_messages.joins(:request_message).where(
      "request_messages.expiration_date > :query_now AND request_messages.expiration_date <= :query_tomorrow",
      query_now: DateTime.now, query_tomorrow: DateTime.now + 1.day
    )

    messages = @account.inbox_messages
    if top_messages.count > 0
      messages = messages.where.not(id: top_messages.pluck(:id))
    end

    offset = nil
    limit  = nil
    if params[:limit].to_i > top_messages.count
      limit = params[:limit].to_i - top_messages.count

      if params[:offset].to_i > top_messages.count
        offset = params[:offset].to_i - top_messages.count
      end
    end
    messages = messages.order(:created_at => :desc).limit(limit).offset(offset)

    render json: (top_messages + messages), status: :ok
  end

  # GET account/1/inbox_messages/1
  swagger_api :show do
    summary "Retrieve message"
    param :path, :account_id, :integer, :required, "Authorized account id"
    param :path, :id, :integer, :required, "Message id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :unauthorized
  end
  def show
    if @message.receiver_id == params[:account_id].to_i or @message.sender_id == params[:account_id].to_i
      render json: @message, extended: true, status: :ok
    else
      render status: :not_found
    end
  end

  # GET account/1/inbox_messages/my
  swagger_api :my do
    summary "Retrieve message"
    param :path, :account_id, :integer, :required, "Authorized account id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :unauthorized
  end
  def my
    render json: @account.sent_messages.order(:created_at => :desc).limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # POST account/1/inbox_messages/1/change_responce_time
  swagger_api :change_responce_time do
    summary "Change message's time to responce"
    param :path, :account_id, :integer, :required, "Authorized account id"
    param :path, :id, :integer, :required, "Message id"
    param_list :form, :time_frame, :integer, :required, "Time frame to answer", ["two_hours", "two_days", "one_week"]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :unauthorized
  end
  def change_responce_time
    if @message.sender_id == params[:account_id].to_i and @message.request_message != nil
      @message.request_message.time_frame = params[:time_frame]
      @message.save!

      render json: @message, extended: true, status: :ok
    else
      render status: :not_found
    end
  end

  # DELETE account/1/inbox_messages/1
  swagger_api :destroy do
    summary "Delete message"
    param :path, :account_id, :integer, :required, "Account id"
    param :path, :id, :integer, :required, "Message id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :forbidden
    response :not_found
  end
  def destroy
    if @message.is_read == true and @message.receiver_id == @account.id
      @message.destroy
      render status: :ok
    else
      render status: :forbidden
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = InboxMessage.find(params[:id])
    end

    def authorize_account
      @user = AuthorizeHelper.authorize(request)
      @account = Account.find(params[:account_id])
      render status: :unauthorized if @user == nil or @account.user != @user
    end
end

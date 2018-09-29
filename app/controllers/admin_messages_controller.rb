class AdminMessagesController < ApplicationController
  before_action :authorize_admin
  swagger_controller :admin_messages, "AdminPanel"

  swagger_api :index do
    summary "Retrieve list of dialogs"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def index
    topics = AdminTopic.where(sender_id: @admin.id, sender_deleted: false).or(
      AdminTopic.where(receiver_id: @admin.id, receiver_deleted: false)).order(created_at: :desc)

    render json: topics.limit(params[:limit]).offset(params[:offset]), my_id: @admin.id, status: :ok
  end

  swagger_api :show do
    summary "Get messages"
    param :path, :id, :integer, :required, "Topic id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def show
    topic = AdminTopic.find(params[:id])
    if topic.sender == @admin
      messages = AdminMessage.where(topic_id: topic.id, sender_deleted: false).order(created_at: :desc)
    else
      messages = AdminMessage.where(topic_id: topic.id, receiver_deleted: false).order(created_at: :desc)
    end

    render json: messages.limit(params[:limit]).offset(params[:offset]).reverse, status: :ok
  end

  swagger_api :read do
    summary "Read messages"
    param :path, :id, :integer, :required, "Topic id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def read
    topic = AdminTopic.find(params[:id])
    messages = topic.admin_messages.where(is_read: false).where.not(sender_id: @admin.id)

    if messages.update_all(is_read: true)
      count = @admin.send_topics.joins(:admin_messages).where(admin_messages: {is_read: false}).where.not(sender_id: @admin.id).count +
        @admin.received_topics.joins(:admin_messages).where(admin_messages: {is_read: false}).where.not(sender_id: @admin.id).count
      AdminMessagesChannel.broadcast_to(@admin.id, count: count)

      render status: :ok
    else
      render status: :unprocessable_entity
    end
  end

  # GET /admin/messages/topics
  swagger_api :topics_search do
    summary "Search for message topics"
    param :query, :text, :string, :optional, "Message topic"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def topics_search
    @topics = AdminTopic.search(params[:text])

    render json: @topics.limit(params[:limit]).offset(params[:offset]).as_json(only: :topic), status: :ok
  end

  # POST /admin/messages/new
  swagger_api :new do
    summary "Create new dialog"
    param :form, :receivers_ids, :string, :required, "Array of receivers ids"
    param :form, :message, :string, :optional, "Message"
    param :form, :topic, :string, :required, "Topic"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def new
    params[:receivers_ids].each do |receiver_id|
      receiver = Admin.find(receiver_id)
      unless receiver
        next
      end

      topic = AdminTopic.new(
        sender_id: @admin.id,
        receiver_id: receiver.id,
        topic: params[:topic],
        topic_type: 'message'
      )
      if topic.save
        message = AdminMessage.new(
          sender_id: @admin.id,
          message: params[:message],
          topic_id: topic.id
        )
        if message.save
          count = receiver.send_topics.joins(:admin_messages).where(admin_messages: {is_read: false}).where.not(sender_id: receiver.id).count +
            receiver.received_topics.joins(:admin_messages).where(admin_messages: {is_read: false}).where.not(sender_id: receiver.id).count
          AdminMessagesChannel.broadcast_to(receiver.id, count: count)
        else
          topic.destroy
        end
      end
    end

    render status: :created
  end

  # POST /admin/messages
  swagger_api :create do
    summary "Send message"
    param :form, :topic_id, :integer, :required, "Topic id"
    param :form, :receiver_id, :integer, :required, "Receiver id"
    param :form, :message, :string, :optional, "Message"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def create
    receiver = Admin.find(params[:receiver_id])
    unless receiver
      render json: {error: ADMIN_NOT_FOUND}, status: :not_found and return
    end

    topic = AdminTopic.find(params[:topic_id])
    unless topic
      render json: {error: DIALOG_NOT_FOUND}, status: :not_found and return
    end

    message = AdminMessage.new(
      sender_id: @admin.id,
      message: params[:message],
      topic_id: topic.id
    )
    if message.save
      count = receiver.send_topics.joins(:admin_messages).where(admin_messages: {is_read: false}).where.not(sender_id: receiver.id).count +
        receiver.received_topics.joins(:admin_messages).where(admin_messages: {is_read: false}).where.not(sender_id: receiver.id).count
      AdminMessagesChannel.broadcast_to(receiver.id, count: count)

      render status: :created
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end

  # POST /admin/messages/1/forward
  swagger_api :forward do
    summary "Forward message"
    param :path, :id, :string, :optional, "Message id"
    param :form, :receiver_id, :string, :required, "Receiver id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def forward
    message = AdminMessage.find(params[:id])
    unless message
      render json: {error: MESSAGE_NOT_FOUND}, status: :not_found and return
    end

    receiver = Admin.find(params[:receiver_id])
    unless receiver
      render json: {error: ADMIN_NOT_FOUND}, status: :not_found and return
    end

    topic = AdminTopic.new(
      sender_id: @admin.id,
      receiver_id: receiver.id,
      topic: message.admin_topic.topic,
      topic_type: 'message'
    )
    if topic.save
      message = AdminMessage.new(
        sender_id: @admin.id,
        forwarded_message: message.message,
        forwarded_from: message.sender.id,
        forwarder_type: 'admin',
        topic_id: topic.id
      )
      if message.save
        count = receiver.send_topics.joins(:admin_messages).where(admin_messages: {is_read: false}).where.not(sender_id: receiver.id).count +
          receiver.received_topics.joins(:admin_messages).where(admin_messages: {is_read: false}).where.not(sender_id: receiver.id).count
        AdminMessagesChannel.broadcast_to(receiver.id, count: count)

        render status: :created
      else
        render json: message.errors, status: :unprocessable_entity
        topic.destroy
      end
    else
      render json: topic.errors, status: :unprocessable_entity
    end
  end

  # POST /admin/messages/1/solve
  swagger_api :solve do
    summary "Solve bug"
    param :path, :id, :string, :optional, "Dialog id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def solve
    topic = AdminTopic.find(params[:id])

    if topic
      topic.is_solved = true

      if topic.save
        render status: :ok
      else
        render json: topic.errors, status: :unprocessable_entity
      end
    else
      render status: :not_found
    end
  end

  # DELETE /admin/messages/1/delete
  swagger_api :delete do
    summary "Delete dialog"
    param :path, :id, :string, :optional, "Dialog id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def delete
    topic = AdminTopic.find(params[:id])

    if topic
      if topic.sender_id == topic.receiver_id and topic.sender_id == @admin.id
        topic.destroy

        render status: :ok and return
      elsif topic.sender_id == @admin.id
        if topic.receiver_deleted
          topic.destroy

          render status: :ok and return
        else
          topic.sender_deleted = true
          topic.save

          render status: :ok and return
        end
      elsif topic.receiver_id == @admin.id
        if topic.sender_deleted
          topic.destroy

          render status: :ok and return
        else
          topic.receiver_deleted = true
          topic.save

          render status: :ok and return
        end
      end
      render status: :unprocessable_entity and return
    else
      render status: :not_found
    end
  end

  # DELETE /admin/messages/1/delete_message
  swagger_api :delete_message do
    summary "Solve bug"
    param :path, :id, :string, :optional, "Dialog id"
    param :form, :message_id, :string, :optional, "Message id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def delete_message
    message = AdminMessage.find(params[:message_id])

    if message
      if message.admin_topic.sender_id == @admin.id
        if message.receiver_deleted
          message.destroy

          render status: :ok and return
        else
          message.sender_deleted = true
          message.save

          render status: :ok and return
        end
      elsif message.admin_topic.receiver_id == @admin.id
        if message.sender_deleted
          message.destroy

          render status: :ok and return
        else
          message.receiver_deleted = true
          message.save

          render status: :ok and return
        end
      end
      render status: :unprocessable_entity and return
    else
      render status: :not_found
    end
  end

  private
  def authorize_admin
    user = AuthorizeHelper.authorize(request)
    render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)

    @admin = user.admin
  end

  def authorize_admin_and_set_user
    @user = AuthorizeHelper.authorize(request)
    render status: :unauthorized and return if @user == nil or (@user.is_superuser == false and @user.is_admin == false)
  end
end
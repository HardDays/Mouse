class AdminMessagesController < ApplicationController
  before_action :authorize_admin
  before_action :authorize_admin_and_set_user, only: [:get_my]
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
      messages = AdminMessage.where(sender_deleted: false).order(created_at: :desc)
    else
      messages = AdminMessage.where(receiver_deleted: false).order(created_at: :desc)
    end

    render json: messages.limit(params[:limit]).offset(params[:offset]).reverse, status: :ok
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
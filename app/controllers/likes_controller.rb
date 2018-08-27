class LikesController < ApplicationController
  before_action :set_event, only: [:create, :destroy]
  before_action :authorize_user, only: [:create, :destroy]
  swagger_controller :likes, "Likes"

  # GET /events/1/likes
  swagger_api :index do
    summary "Retrieve list of likes"
    param :path, :event_id, :integer, :required, "Event id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    @likes = Like.where(event_id: params[:event_id])

    render json: @likes.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # POST /events/1/likes
  swagger_api :create do
    summary "Like event"
    param :path, :event_id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def create
    obj = Like.new(event_id: @event.id, user_id: @user.id, account_id: params[:account_id])
    obj.save!

    render status: :ok
  end

  # DELETE /events/1/likes
  swagger_api :destroy do
    summary "Unlike event"
    param :path, :event_id, :integer, :required, "Event id"
    param :path, :id, :integer, :required, "Like id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def destroy
    obj = Like.find_by(event_id: @event, user_id: @user)
    if not obj
      render status: :not_found
    else
      obj.destroy
      render status: :ok
    end
  end

  private
  def set_event
    @event = Event.find(params[:event_id])
  end

  def authorize
    @user = AuthorizeHelper.authorize(request)
    return @user != nil
  end

  def authorize_user
    render status: :forbidden if not authorize
  end
end
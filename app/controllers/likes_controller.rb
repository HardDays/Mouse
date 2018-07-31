class LikesController < ApplicationController
  before_action :set_feed_item, only: [:index, :create, :destroy]
  before_action :authorize_user, only: [:create, :destroy]
  swagger_controller :likes, "Likes"

  # GET /events/1/likes
  swagger_api :index do
    summary "Retrieve list of likes"
    param :path, :feed_item_id, :integer, :required, "Feed item id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    @likes = @feed_item.likes

    render json: @likes.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # POST /events/1/likes
  swagger_api :create do
    summary "Like event"
    param :path, :feed_item_id, :integer, :required, "Feed item id"
    param :form, :account_id, :integer, :required, "Account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def create
    obj = Like.new(feed_item_id: @feed_item.id, user_id: @user.id, account_id: params[:account_id])
    obj.save!

    render status: :ok
  end

  # DELETE /events/1/likes
  swagger_api :destroy do
    summary "Unlike event"
    param :path, :feed_item_id, :integer, :required, "Feed item id"
    param :path, :id, :integer, :required, "Like id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def destroy
    obj = Like.find_by(feed_item_id: @feed_item.id, user_id: @user)
    if not obj
      render status: :not_found
    else
      obj.destroy
      render status: :ok
    end
  end

  private
  def set_feed_item
    @feed_item = FeedItem.find(params[:feed_item_id])
  end

  def authorize
    @user = AuthorizeHelper.authorize(request)
    return @user != nil
  end

  def authorize_user
    render status: :forbidden if not authorize
  end
end
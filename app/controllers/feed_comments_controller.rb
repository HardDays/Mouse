class FeedCommentsController < ApplicationController
  before_action :authorize_account, only: :create
  swagger_controller :comments, "Comments"

  # GET events/1/comments
  swagger_api :index do
    summary "Retrieve list of comments"
    param :path, :account_id, :integer, :required, "Event id"
    param :path, :feed_item_id, :integer, :required, "Event id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
  end

  def index
    @comments = Comment.where(feed_item_id: params[:feed_item_id])

    render json: @comments.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # POST events/1/comments
  swagger_api :create do
    summary "Create a comment"
    param :path, :feed_item_id, :integer, :required, "Feed item id"
    param :path, :account_id, :integer, :required, "Fan account id"
    param :form, :text, :string, :required, "Text"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :forbidden
  end

  def create
    feed_item = FeedItem.find(params[:feed_item_id])

    @comment = Comment.new(comment_params)
    @comment.feed_item = feed_item
    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private
  def comment_params
    params.permit(:account_id, :text)
  end

  def authorize_account
    @account = AuthorizeHelper.auth_and_set_account(request)

    if @account == nil
      render json: {error: "Access forbidden"}, status: :forbidden and return
    end
  end
end

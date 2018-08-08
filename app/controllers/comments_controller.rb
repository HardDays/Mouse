class CommentsController < ApplicationController
  before_action :authorize_account, only: :create
  before_action :check_event, only: :create
  swagger_controller :comments, "Comments"

  # GET events/1/comments
  swagger_api :index do
    summary "Retrieve list of comments"
    param :path, :event_id, :integer, :required, "Event id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
  end
  def index
    @comments = Comment.joins(:feed_item => :event_update).where(event_updates: {event_id: params[:event_id]})

    render json: @comments.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # POST events/1/comments
  swagger_api :create do
    summary "Create a comment"
    param :path, :event_id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Fan account id"
    param :form, :text, :string, :required, "Text"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :forbidden
  end
  def create
    feed_item = @event.event_updates.where(action: EventUpdate.actions["add_event"]).first

    # TODO: delete this
    if feed_item
      feed_item = feed_item.feed_item
    else
      action = EventUpdate.new(action: :add_event, updated_by: @event.creator_id, event_id: @event.id)
      action.save
      feed_item = FeedItem.new(event_update_id: action.id)
      feed_item.save
    end

    @comment = Comment.new(comment_params)
    @comment.feed_item = feed_item
    @comment.account_id = @account.id
    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private
    def comment_params
      params.permit(:text)
    end

    def check_event
      @event = Event.find(params[:event_id])
      render status: :unprocessable_entity if @event == nil or @event.comments_available == false
    end

    def authorize_account
      @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])

      if @account == nil
        render json: {error: "Access forbidden"}, status: :forbidden and return
      end
    end
end

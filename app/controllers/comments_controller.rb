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
    @comments = Comment.where(event_id: params[:event_id]).order(created_at: :desc)

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
    @comment = Comment.new(comment_params)
    @comment.fan_id = @account.id

    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private
    def comment_params
      params.permit(:text, :event_id)
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

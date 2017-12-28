class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update, :destroy]
  before_action :authorize_account, only: :create
  swagger_controller :comments, "Comments"

  # GET events/1/comments
  swagger_api :index do
    summary "Retrieve list of comments"
    param :path, :event_id, :integer, :required, "Event id"
    param :query, :limit, :integer, :required, "Limit"
    param :query, :offset, :integer, :required, "Offset"
  end
  def index
    @comments = Comment.where(event_id: params[:event_id])

    render json: @comments.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # GET /comments/1
  def show
    render json: @comment
  end

  # POST events/1/comments
  swagger_api :create do
    summary "Create a comment"
    param :path, :event_id, :integer, :required, "Event id"
    param :form, :fan_id, :integer, :required, "Fan id"
    param :form, :text, :string, :required, "Text"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :forbidden
  end
  def create
    @comment = Comment.new(comment_params)

    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.permit(:event_id, :fan_id, :text)
    end

    def authorize_account
      @user = AuthorizeHelper.authorize(request)
      @account = Account.find(params[:fan_id])
      render status: :unauthorized if @user == nil or @account.user != @user or @account.account_type != 'fan'
    end
end

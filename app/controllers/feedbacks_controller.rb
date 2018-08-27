class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show]
  before_action :authorize_user, only: [:create]
  swagger_controller :feedbacks, "Feedback"

  # GET /feedbacks
  swagger_api :index do
    summary "Retrieve feedback messages"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    @feedbacks = Feedback.all

    render json: @feedbacks.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # GET /feedbacks/1
  swagger_api :show do
    summary "Retrieve feedback message"
    param :path, :id, :integer, :required, "Feedback item id"
    response :not_found
    response :ok
  end
  def show
    render json: @feedback, status: :ok
  end

  # POST /feedbacks
  swagger_api :create do
    summary "Send feedback"
    param :form, :account_id, :integer, :optional, "Account id"
    param_list :form, :feedback_type, :string, :required, "Type of feedback", ["bug", "enhancement", "compliment"]
    param :form, :detail, :string, :optional, "Message text"
    param :form, :rate_score, :string, :required, "Rate score"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :created
  end
  def create
    @feedback = Feedback.new(feedback_params)

    if params[:account_id]
      @feedback.account = Account.find(params[:account_id])
    else
      @feedback.account = @user.accounts.first
    end

    if @feedback.save
      render json: @feedback, status: :created
    else
      render json: @feedback.errors, status: :unprocessable_entity
    end
  end


  private
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    def authorize_user
      @user = AuthorizeHelper.authorize(request)
      render status: :unauthorized if @user == nil
    end

    def feedback_params
      params.permit(:feedback_type, :detail, :rate_score)
    end
end

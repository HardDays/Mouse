class AdminFeedbackController < ApplicationController
  before_action :authorize_admin
  swagger_controller :admin_feedback, "AdminPanel"

  # GET /admin/feedbacks
  swagger_api :index do
    summary "Retrieve feedback list"
    param_list :query, :feedback_type, :string, :optional, "Type of feedback", [:all, :bug, :enhancement, :compliment]
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def index
    feedback = Feedback.all

    if params[:feedback_type] and params[:feedback_type] != 'all'
      feedback = feedback.where(feedback_type: params[:feedback_type])
    end

    render json: feedback.limit(params[:limit]).offset(params[:offset]),
           each_serializer: SimpleFeedbackSerializer, status: :ok
  end

  # GET /admin/feedbacks/overall
  swagger_api :overall do
    summary "Overall score"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def overall
    feedback = Feedback.pluck('sum(feedbacks.rate_score), count(feedbacks.id)').first

    render json: feedback[0] / feedback[1], status: :ok
  end

  # GET /admin/feedbacks/counts
  swagger_api :counts do
    summary "Get number of feedback of each type"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def counts
    render json: {
      bug: Feedback.where(feedback_type: 'bug').count,
      enhancement: Feedback.where(feedback_type: 'enhancement').count,
      compliment: Feedback.where(feedback_type: 'compliment').count
    }, status: :ok
  end

  # GET /admin/feedbacks/1
  swagger_api :show do
    summary "Retrieve question item"
    param :path, :id, :integer, :required, "Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def show
    feedback = Feedback.find(params[:id])
    render json: feedback, serializer: FeedbackSerializer, status: :ok
  end

  # POST /admin/feedbacks/1/thank_you
  swagger_api :thank_you do
    summary "Reply on question"
    param :path, :id, :integer, :required, "Id"
    param :form, :message, :string, :required, "Message"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def thank_you
    feedback = Feedback.find(params[:id])

    redern status: :ok
  end

  # DELETE /admin/feedbacks/1
  swagger_api :destroy do
    summary "Destroy question"
    param :path, :id, :integer, :required, "Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def destroy
    feedback = Feedback.find(params[:id])
    feedback.destroy

    render status: :ok
  end

  private
  def authorize_admin
    user = AuthorizeHelper.authorize(request)

    render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)
    @admin = user.admin
  end
end
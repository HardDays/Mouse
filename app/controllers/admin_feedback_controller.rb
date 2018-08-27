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
    feedback = Feedback.all.order(:created_at => :desc)

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


  # GET /admin/feedbacks/graph
  swagger_api :graph do
    summary "Get feedback info for graph"
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def graph
    if params[:by] == 'all'
      dates = Feedback.pluck("min(created_at), max(created_at)").first
      diff = Time.diff(dates[0], dates[1])
      if diff[:month] > 0
        new_step = 'year'
      elsif diff[:week] > 0
        new_step = 'month'
      elsif diff[:day] > 0
        new_step = 'week'
      else
        new_step = 'day'
      end

      axis = GraphHelper.custom_axis(new_step, dates)
      dates_range = dates[0]..dates[1]
      params[:by] = new_step
    else
      axis = GraphHelper.axis(params[:by])
      dates_range = GraphHelper.sql_date_range(params[:by])
    end

    feed = Feedback.where(
      created_at: dates_range
    ).order(:feedback_type, :created_at).to_a.group_by(
      &:feedback_type
    ).each_with_object({}) {
      |(k, v), h| h[k] = v.group_by{ |e| e.created_at.strftime(GraphHelper.type_str(params[:by])) }
    }.each { |(k, h)|
      h.each { |m, v|
        h[m] = v.count
      }
    }

    render json: {
      axis: axis,
      bugs: feed['bug'],
      enhancement: feed['enhancement'],
      compliment: feed['compliment'],
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

    feedback_reply = InboxMessage.new(
      name: "Admin's reply to your feedback",
      message_type: "blank",
      simple_message: params[:message]
    )
    feedback_reply.admin = @admin
    feedback_reply.receiver = feedback.account
    if feedback_reply.save!
      feedback.reply = feedback_reply
      feedback.save

      render json: feedback_reply, status: :created
    else
      render json: feedback_reply.errors, status: :unprocessable_entity
    end
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
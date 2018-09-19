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
    feedback = InboxMessage.joins(:feedback_message).order(:created_at => :desc)

    if params[:feedback_type] and params[:feedback_type] != 'all'
      feedback = feedback.where(feedbacks: {feedback_type: Feedback.feedback_type[params[:feedback_type]]})
    end

    render json: feedback.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # GET /admin/feedbacks/overall
  swagger_api :overall do
    summary "Overall score"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def overall
    feedback = InboxMessage.joins(:feedback_message).where(
      inbox_messages: {is_parent: true}
    ).pluck('sum(feedbacks.rate_score), count(feedbacks.id)').first

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
      bug: InboxMessage.joins(:feedback_message).where(feedbacks: {feedback_type: Feedback.feedback_types['bug']}).count,
      enhancement: InboxMessage.joins(:feedback_message).where(feedbacks: {feedback_type: Feedback.feedback_types['enhancement']}).count,
      compliment: InboxMessage.joins(:feedback_message).where(feedbacks: {feedback_type: Feedback.feedback_types['compliment']}).count
    }, status: :ok
  end


  # GET /admin/feedbacks/graph
  swagger_api :graph do
    summary "Get feedback info for graph"
    param_list :query, :by, :string, :required, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def graph
    if params[:by] == 'all'
      dates = InboxMessage.joins(:feedback_message).pluck("min(inbox_messages.created_at), max(inbox_messages.created_at)").first
      if dates
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

    feed = InboxMessage.joins(:feedback_message).where(
      created_at: dates_range
    ).order("feedbacks.feedback_type, inbox_messages.created_at").to_a.group_by{ |e|
      e.feedback_message.feedback_type
    }.each_with_object({}) {
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
    feedback = InboxMessage.joins(:feedback_message).find(params[:id])
    render json: feedback, extended: true, status: :ok
  end

  # POST /admin/feedbacks/1/thank_you
  swagger_api :thank_you do
    summary "Reply on question"
    param :path, :id, :integer, :required, "Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def thank_you
    feedback = InboxMessage.joins(:feedback_message).find(params[:id])

    feedback_reply = InboxMessage.new(
      subject: "Admin's reply to your feedback",
      message_type: "feedback",
      message: "Thank you for your feedback",
      is_parent: false
    )
    feedback_reply.admin = @admin
    feedback_reply.receiver = feedback.sender
    if feedback_reply.save!
      feedback.reply = feedback_reply
      feedback.save

      render json: feedback_reply, status: :created
    else
      render json: feedback_reply.errors, status: :unprocessable_entity
    end
  end

  # POST /admin/feedbacks/1/forward
  swagger_api :forward do
    summary "Reply on question"
    param :path, :id, :integer, :required, "Id"
    param :form, :receiver_id, :integer, :required, "Receiver id"
    param :form, :message, :string, :optional, "Additional message"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def forward
    feedback = InboxMessage.joins(:feedback_message).find(params[:id])
    unless feedback
      render json: {error: MESSAGE_NOT_FOUND}, status: :not_found and return
    end

    receiver = Admin.find(params[:receiver_id])
    unless receiver
      render json: {error: ADMIN_NOT_FOUND}, status: :not_found and return
    end

    topic = AdminTopic.new(
      sender_id: @admin.id,
      receiver_id: receiver.id,
      topic: 'bug',
      topic_type: 'bug'
    )
    if topic.save
      message = AdminMessage.new(
        sender_id: @admin.id,
        message: params[:message],
        forwarded_message: feedback.message,
        forwarded_from: feedback.sender.id,
        forwarder_type: 'account',
        topic_id: topic.id
      )
      if message.save
        feedback.feedback_message.is_forwarded = true
        feedback.feedback_message.save

        count = AdminMessage.where(is_read: false).where.not(sender_id: receiver.id).count
        AdminMessagesChannel.broadcast_to(receiver.id, count: count)

        render status: :created
      else
        render json: message.errors, status: :unprocessable_entity
        topic.destroy
      end
    else
      render json: topic.errors, status: :unprocessable_entity
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
    feedback = InboxMessage.joins(:feedback_message).find(params[:id])
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
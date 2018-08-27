class AdminQuestionsController < ApplicationController
  before_action :authorize_admin
  swagger_controller :admin_questions, "AdminPanel"

  # GET /admin/questions
  swagger_api :index do
    summary "Retrieve questions list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def index
    questions = Question.all.order(:created_at => :desc)

    render json: questions.limit(params[:limit]).offset(params[:offset]),
                each_serializer: SimpleQuestionSerializer, status: :ok
  end

  # GET /admin/questions/1
  swagger_api :show do
    summary "Retrieve question item"
    param :path, :id, :integer, :required, "Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def show
    question = Question.find(params[:id])
    render json: question, serializer: QuestionSerializer, status: :ok
  end

  # POST /admin/questions/1/reply
  swagger_api :reply do
    summary "Reply on question"
    param :path, :id, :integer, :required, "Id"
    param :form, :subject, :string, :required, "Subject"
    param :form, :message, :string, :required, "Message"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def reply
    question = Question.find(params[:id])

    question_reply = InboxMessage.new(
      name: params[:subject],
      message_type: "blank",
      simple_message: params[:message]
    )
    question_reply.admin = @admin
    question_reply.receiver = question.account
    if question_reply.save!
      question.question_reply = question_reply
      question.save

      render json: question_reply, status: :created
    else
      render json: question_reply.errors, status: :unprocessable_entity
    end
  end

  # DELETE /admin/questions/1
  swagger_api :destroy do
    summary "Destroy question"
    param :path, :id, :integer, :required, "Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def destroy
    question = Question.find(params[:id])
    question.destroy

    render status: :ok
  end

  private
  def authorize_admin
    user = AuthorizeHelper.authorize(request)

    render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)
    @admin = user.admin
  end
end
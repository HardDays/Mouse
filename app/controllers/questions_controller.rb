class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :reply]
  before_action :authorize_user_and_set_account, only: [:create, :reply]
  swagger_controller :questions, "Questions"

  # GET /questions
  swagger_api :index do
    summary "Retrieve questions list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    @questions = InboxMessage.where(message_type: 'support', reply: nil)

    render json: @questions.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # GET /questions/1
  swagger_api :show do
    summary "Retrieve question item"
    param :path, :id, :integer, :required, "Id"
    response :not_found
    response :ok
  end
  def show
    render json: @question, extended: true, status: :ok
  end

  # POST /questions
  swagger_api :create do
    summary "Send question"
    param :form, :account_id, :integer, :optional, "Account id"
    param :form, :subject, :string, :required, "Subject of question"
    param :form, :message, :string, :required, "Message"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :created
  end
  def create
    @question = InboxMessage.new(question_params)
    @question.sender_id = @account.id
    @question.message_type = 'support'

    if @question.save
      render json: @question, status: :created
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end

  # POST /questions/:id/reply
  swagger_api :reply do
    summary "Reply to question"
    param :form, :id, :integer, :optional, "Message id"
    param :form, :account_id, :integer, :optional, "Account id"
    param :form, :subject, :string, :required, "Subject of question"
    param :form, :message, :string, :required, "Message"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :created
  end
  def reply
    @reply = InboxMessage.new(question_params)
    @reply.sender_id = @account.id
    @reply.reply = @question
    @reply.message_type = 'support'

    if @reply.save
      render json: @question, extended: true, status: :created
    else
      render json: @reply.errors, status: :unprocessable_entity
    end
  end

  private
    def set_question
      @question = InboxMessage.find(params[:id])
    end

    def authorize_user_and_set_account
      user = AuthorizeHelper.authorize(request)
      render status: :unauthorized and return if user == nil

      @account = user.accounts.find(params[:account_id])
    end

    def question_params
      params.permit(:subject, :message)
    end
end

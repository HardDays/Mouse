class QuestionsController < ApplicationController
  before_action :set_question, only: [:show]
  before_action :authorize_user, only: [:create]
  swagger_controller :questions, "Questions"

  # GET /questions
  swagger_api :index do
    summary "Retrieve questions list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    @questions = Question.all

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
    render json: @question, status: :ok
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
    @question = Question.new(question_params)

    if params[:account_id]
      @question.account = Account.find(params[:account_id])
    else
      @question.account = @user.accounts.first
    end

    if @question.save
      render json: @question, status: :created, location: @question
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end

    def authorize_user
      @user = AuthorizeHelper.authorize(request)
      render status: :unauthorized if @user == nil
    end

    def question_params
      params.permit(:user_id, :subject, :message)
    end
end

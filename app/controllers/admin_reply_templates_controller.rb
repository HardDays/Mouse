class AdminReplyTemplatesController < ApplicationController
  before_action :authorize_admin
  swagger_controller :admin_reply_templates, "AdminPanel"

  # GET /admin/reply_templates
  swagger_api :index do
    summary "Retrieve templates list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def index
    templates = ReplyTemplate.all.order(:created_at => :desc)

    render json: templates.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # GET /admin/reply_templates/to_answer
  swagger_api :to_answer do
    summary "Retrieve approved templates list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def to_answer
    templates = ReplyTemplate.where(status: 'approved').order(:created_at => :desc)

    render json: templates.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # GET /admin/reply_templates/1
  swagger_api :show do
    summary "Retrieve template item"
    param :path, :id, :integer, :required, "Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def show
    template = ReplyTemplate.find(params[:id])
    render json: template, status: :ok
  end

  # POST /admin/reply_templates/
  swagger_api :create do
    summary "Create template"
    param :form, :subject, :string, :required, "Subject"
    param :form, :message, :string, :required, "Message"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def create
    template = ReplyTemplate.new(reply_template_params)
    template.status = 'added'

    if template.save!
      render json: template, status: :created
    else
      render json: template.errors, status: :unprocessable_entity
    end
  end

  # POST /admin/reply_templates/1
  swagger_api :update do
    summary "Create template"
    param :path, :id, :integer, :required, "Id"
    param :form, :subject, :string, :required, "Subject"
    param :form, :message, :string, :required, "Message"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def update
    template = ReplyTemplate.find(params[:id])

    if template.update(reply_template_params)
      render json: template, status: :ok
    else
      render json: template.errors, status: :unprocessable_entity
    end
  end

  # POST /admin/reply_templates/1/approve
  swagger_api :approve do
    summary "Approve template"
    param :path, :id, :integer, :required, "Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :created
  end
  def approve
    template = ReplyTemplate.find(params[:id])
    template.status = 'approved'

    if template.save!
      render json: template, status: :ok
    else
      render json: template.errors, status: :unprocessable_entity
    end
  end

  # DELETE /admin/reply_templates/1
  swagger_api :destroy do
    summary "Destroy template"
    param :path, :id, :integer, :required, "Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def destroy
    template = ReplyTemplate.find(params[:id])
    template.destroy

    render status: :ok
  end

  private
  def authorize_admin
    user = AuthorizeHelper.authorize(request)

    render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)
    @admin = user.admin
  end

  def reply_template_params
    params.permit(:subject, :message)
  end
end
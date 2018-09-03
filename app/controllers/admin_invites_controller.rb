class AdminInvitesController < ApplicationController
  before_action :authorize_admin, only: [:show, :index, :destroy]
  before_action :set_artist_invite, only: [:show, :destroy]

  swagger_controller :admin_invites, "AdminPanel"

  # GET /admin/artist_invites
  swagger_api :index do
    summary "Get artist invites"
    param_list :query, :invite_type, :required, "Invite type", [:all, :artist, :venue, :fan]
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def index
    @invites = Invite.all

    if params[:invite_type] != 'all'
      @invites = @invites.where(invited_type: Invite.invited_types[params[:invite_type]])
    end

    render json: @invites.limit(params[:limit]).offset(params[:offset]).order(created_at: :desc)
  end

  # GET /admin/artist_invites/1
  swagger_api :show do
    summary "Get artist invite by id"
    param :path, :id, :integer, :required, "Invite id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def show
    render json: @invite
  end

  # DELETE /admin/artist_invites/1
  swagger_api :destroy do
    summary "Destroy artist invite by id"
    param :path, :id, :integer, :required, "Invite id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def destroy
    @invite.destroy
  end

  private
  def authorize_admin
    user = AuthorizeHelper.authorize(request)
    render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)

    @admin = user.admin
  end

  def set_artist_invite
    @invite = Invite.find(params[:id])
  end
end

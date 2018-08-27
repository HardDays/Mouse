class ArtistInvitesController < ApplicationController
  before_action :authorize_admin, only: [:show, :index, :destroy]
  before_action :authorize_account, only: [:create]

  before_action :set_artist_invite, only: [:show, :destroy]

  swagger_controller :admin_artist_invites, "AdminPanel"

  # GET /admin/artist_invites
  swagger_api :index do
    summary "Get artist invites"
    param :form, :limit, :integer, :optional, "Limit"
    param :form, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def index
    @artist_invites = ArtistInvite.all

    render json: @artist_invites.limit(params[:limit]).offset(params[:offset])
  end

  # GET /admin/artist_invites/1
  swagger_api :show do
    summary "Get artist invite by id"
    param :path, :id, :integer, :required, "Artist invite id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def show
    render json: @artist_invite
  end

  # POST /artist_invites
  swagger_api :create do
    summary "Create artist invite"
    param :form, :account_id, :integer, :required, "Accountn id"
    param :form, :description, :string, :optional, "Description"
    param :form, :email, :string, :optional, "Email"
    param :form, :name, :string, :optional, "Name"
    param :form, :facebook, :string, :optional, "Facebook"
    param :form, :twitter, :string, :optional, "Twitter"
    param :form, :vk, :string, :optional, "Vk"
    param :form, :youtube, :string, :optional, "Youtube"
    param :form, :links, :string, :optional, "Links to artist"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def create
    @artist_invite = ArtistInvite.new(artist_invite_params)
    @artist_invite.account_id = params[:account_id]

    if @artist_invite.save
      render json: @artist_invite, status: :created
    else
      render json: @artist_invite.errors, status: :unprocessable_entity
    end
  end

  # DELETE /admin/artist_invites/1
  swagger_api :destroy do
    summary "Destroy artist invite by id"
    param :path, :id, :integer, :required, "Artist invite id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def destroy
    @artist_invite.destroy
  end

  private
    def authorize_admin
      user = AuthorizeHelper.authorize(request)
      render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)

      @admin = user.admin
    end

    def authorize_account
      @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])
  
      if @account == nil
        render json: {error: "Access forbidden"}, status: :forbidden and return
      end
  
      @user = @account.user
    end
    
    def set_artist_invite
      @artist_invite = ArtistInvite.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def artist_invite_params
      params.permit(:description, :links, :email, :name, :vk, :youtube, :twitter, :facebook)
    end
end

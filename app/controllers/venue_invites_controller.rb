class VenueInvitesController < ApplicationController
  before_action :authorize_admin, only: [:show, :index, :destroy]
  before_action :authorize_account, only: [:create]

  before_action :set_venue_invite, only: [:show, :destroy]
  
  swagger_controller :admin_venue_invites, "AdminPanel"

  # GET /admin/venue_invites
  swagger_api :index do
    summary "Get venue invites"
    param :form, :limit, :integer, :optional, "Limit"
    param :form, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def index
    @venue_invites = VenueInvite.all

    render json: @venue_invites.limit(params[:limit]).offset(params[:offset])
  end

  # GET /admin/venue_invites/1
  swagger_api :show do
    summary "Get venue invite by id"
    param :path, :id, :integer, :required, "Venue invite id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def show
    render json: @venue_invite
  end

  # POST /venue_invites
  swagger_api :create do
    summary "Create venue invite"
    param :form, :account_id, :integer, :required, "Accountn id"
    param :form, :description, :string, :required, "Description"
    param :form, :email, :string, :optional, "Email"
    param :form, :name, :string, :optional, "Name"
    param :form, :facebook, :string, :optional, "Facebook"
    param :form, :twitter, :string, :optional, "Twitter"
    param :form, :vk, :string, :optional, "Vk"
    param :form, :youtube, :string, :optional, "Youtube"
    param :form, :links, :string, :optional, "Links to venue"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def create
    @venue_invite = VenueInvite.new(venue_invite_params)
    @venue_invite.account_id = params[:account_id]

    if @venue_invite.save
      render json: @venue_invite, status: :created
    else
      render json: @venue_invite.errors, status: :unprocessable_entity
    end
  end

  # DELETE /admin/venue_invites/1
  swagger_api :destroy do
    summary "Destroy venue invite by id"
    param :path, :id, :integer, :required, "Venue invite id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def destroy
    @venue_invite.destroy
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
    
    def set_venue_invite
      @venue_invite = VenueInvite.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def venue_invite_params
      params.permit(:description, :links, :email, :name, :vk, :youtube, :twitter, :facebook)
    end
end

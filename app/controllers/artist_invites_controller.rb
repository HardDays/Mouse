class ArtistInvitesController < ApplicationController
  before_action :authorize_account, only: [:create]

  swagger_controller :artist_invites, "Artist invites"

  # POST /artist_invites
  swagger_api :create do
    summary "Create artist invite"
    param :form, :account_id, :integer, :required, "Account id"
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
    @artist_invite = Invite.new(artist_invite_params)
    @artist_invite.account_id = params[:account_id]
    @artist_invite.invited_type = 'artist'

    if @artist_invite.save
      render json: @artist_invite, status: :created
    else
      render json: @artist_invite.errors, status: :unprocessable_entity
    end
  end

  private
    def authorize_account
      @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])
  
      if @account == nil
        render json: {error: "Access forbidden"}, status: :forbidden and return
      end
  
      @user = @account.user
    end

    # Only allow a trusted parameter "white list" through.
    def artist_invite_params
      params.permit(:description, :links, :email, :name, :vk, :youtube, :twitter, :facebook)
    end
end

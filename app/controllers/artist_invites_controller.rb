class ArtistInvitesController < ApplicationController
  before_action :authorize_admin, only: [:show, :index, :destroy]
  before_action :authorize_user, only: [:show, :create, :destroy]

  before_action :set_artist_invite, only: [:show, :destroy]

  # GET /artist_invites
  def index
    @artist_invites = ArtistInvite.all

    render json: @artist_invites
  end

  # GET /artist_invites/1
  def show
    render json: @artist_invite
  end

  # POST /artist_invites
  def create
    @artist_invite = ArtistInvite.new(artist_invite_params)

    if @artist_invite.save
      render json: @artist_invite, status: :created
    else
      render json: @artist_invite.errors, status: :unprocessable_entity
    end
  end

  # DELETE /artist_invites/1
  def destroy
    @artist_invite.destroy
  end

  private
    def authorize_admin
      user = AuthorizeHelper.authorize(request)
      render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)

      @admin = user.admin
    end
    
    def set_artist_invite
      @artist_invite = ArtistInvite.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def artist_invite_params
      params.permit(:description, :links)
    end
end

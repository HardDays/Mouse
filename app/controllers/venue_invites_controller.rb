class VenueInvitesController < ApplicationController
  before_action :authorize_account, only: [:create]
  
  swagger_controller :venue_invites, "VenueInvites"

  # POST /venue_invites
  swagger_api :create do
    summary "Create venue invite"
    param :form, :account_id, :integer, :required, "Account id"
    param :form, :description, :string, :optional, "Description"
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
    @venue_invite = Invite.new(venue_invite_params)
    @venue_invite.account_id = params[:account_id]
    @venue_invite.invited_type = 'venue'

    if @venue_invite.save
      render json: @venue_invite, status: :created
    else
      render json: @venue_invite.errors, status: :unprocessable_entity
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
    def venue_invite_params
      params.permit(:description, :links, :email, :name, :vk, :youtube, :twitter, :facebook)
    end
end

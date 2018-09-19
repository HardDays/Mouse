class ArtistRidersController < ApplicationController
  before_action :authorize_account, only: [:create, :destroy]
  before_action :set_account, only: [:index, :show]
  swagger_controller :artist_riders, "Artist Riders"

  swagger_api :index do
    summary "Get artist riders"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
  end
  def index
    riders = @account.artist.artist_riders

    render json: riders.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # GET /artist_riders/1
  swagger_api :show do
    summary "Get full artist riders object"
    param :path, :id, :integer, :required, "Artist rider id"
    response :not_found
  end
  def show
    @rider = ArtistRider.find(params[:id])
    render json: @rider, file_info: true
  end

  swagger_api :create do
    summary "Add album to artist"
    param :path, :account_id, :integer, :required, "Artist account id"
    param_list :form, :rider_type, :string, :required, "Rider type", [:stage, :backstage, :hospitality, :technical]
    param :form, :description, :string, :required, "Rider description"
    param :form, :is_flexible, :boolean, :required, "Is it flexible"
    param :form, :uploaded_file_base64, :string, :required, "file base64"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
  end
  def create
    obj = ArtistRider.new(artist_rider_params)
    obj.artist_id = @account.artist.id
    if obj.save
      @account.artist.artist_riders << obj
      @account.artist.save

      render json: obj, file_info: true, status: :created
    else
      render json: obj.errors, status: :unprocessable_entity
    end
  end

  swagger_api :destroy do
    summary "Delete album"
    param :path, :account_id, :integer, :required, "Account id"
    param :path, :id, :integer, :required, "Rider id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :unauthorized
    response :not_found
  end
  def destroy
    rider = @account.artist.artist_riders.find(params[:id])
    rider.destroy

    render status: :ok
  end

  private
  def set_account
    @account = Account.find(params[:account_id])

    unless @account.account_type == "artist"
      render status: :forbidden and return
    end
  end

  def authorize_account
    @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])

    if @account == nil or @account.artist == nil
      render json: {error: "Access forbidden"}, status: :forbidden and return
    end
  end

  def artist_rider_params
    params.permit(:rider_type, :description, :is_flexible, :uploaded_file_base64)
  end
end
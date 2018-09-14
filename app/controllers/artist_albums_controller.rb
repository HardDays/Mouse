class ArtistAlbumsController < ApplicationController
  before_action :authorize_account, only: [:create, :destroy]
  before_action :set_account, only: [:index, :show]
  swagger_controller :artist_albums, "Artist albums"

  swagger_api :index do
    summary "Get artist albums"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
  end
  def index
    albums = @account.artist.artist_albums

    render json: albums.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  swagger_api :show do
    summary "Get artist album"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :path, :id, :integer, :required, "Artist album id"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
    response :not_found
  end
  def show
    album = @account.artist.artist_albums.find(params[:id])

    render json: album, status: :ok
  end

  swagger_api :create do
    summary "Add album to artist"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :form, :album_name, :string, :required, "Album name"
    param :from, :album_artwork, :string, :required, "Album artwork"
    param :form, :album_link, :string, :required, "Album link"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
  end
  def create
    obj = ArtistAlbum.new(artist_album_params)
    if obj.save
      @account.artist.artist_albums << obj
      @account.artist.save

      LogHelper.log_account_changed_value(:album, @account, obj.id)
      render json: obj, status: :created
    else
      render json: obj.errors, status: :unprocessable_entity
    end
  end

  swagger_api :destroy do
    summary "Delete album"
    param :path, :account_id, :integer, :required, "Account id"
    param :path, :id, :integer, :required, "Album id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :unauthorized
    response :not_found
  end
  def destroy
    album = @account.artist.artist_albums.find(params[:id])
    album.destroy

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

  def artist_album_params
    params.permit(:album_name, :album_artwork, :album_link)
  end
end
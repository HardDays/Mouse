class ArtistVideosController < ApplicationController
  before_action :authorize_account, only: [:index, :show, :create, :destroy]
  swagger_controller :artist_videos, "Artist videos"

  swagger_api :index do
    summary "Get artist videos"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
  end
  def index
    videos = @account.artist.artist_videos

    render json: videos.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  swagger_api :show do
    summary "Get artist video"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :path, :id, :integer, :required, "Artist video id"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
    response :not_found
  end
  def show
    video = @account.artist.artist_videos.find(params[:id])

    render json: video, status: :ok
  end

  swagger_api :create do
    summary "Add audio to artist"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :form, :link, :string, :required, "Link to video"
    param :from, :name, :string, :required, "Song name"
    param :form, :album_name, :string, :required, "Album name"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
  end
  def create
    obj = ArtistVideo.new(artist_video_params)
    if obj.save
      @account.artist.artist_videos << obj
      @account.artist.save

      LogHelper.log_account_changed_value(:video, @account, obj.id)
      render json: obj, status: :created
    else
      render json: obj.errors, status: :unprocessable_entity
    end
  end

  swagger_api :destroy do
    summary "Delete video"
    param :path, :account_id, :integer, :required, "Account id"
    param :path, :id, :integer, :required, "Video id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :unauthorized
    response :not_found
  end
  def destroy
    video = @account.artist.artist_videos.find(params[:id])
    video.destroy

    render status: :ok
  end

  private
  def authorize_account
    @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])

    if @account == nil or @account.artist == nil
      render json: {error: "Access forbidden"}, status: :forbidden and return
    end
  end

  def artist_video_params
    params.permit(:link, :name, :album_name)
  end
end
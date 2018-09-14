class ArtistAudiosController < ApplicationController
  before_action :authorize_account, only: [:create, :destroy]
  before_action :set_account, only: [:index, :show]
  swagger_controller :artist_audios, "Artist audios"

  swagger_api :index do
    summary "Get artist audios"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
  end
  def index
    audios = @account.artist.audio_links

    render json: audios.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  swagger_api :show do
    summary "Get artist audio"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :path, :id, :integer, :required, "Artist audio id"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
    response :not_found
  end
  def show
    audio = @account.artist.audio_links.find(params[:id])

    render json: audio, status: :ok
  end

  swagger_api :create do
    summary "Add audio to artist"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :form, :audio_link, :string, :required, "Link to audio"
    param :from, :song_name, :string, :required, "Song name"
    param :form, :album_name, :string, :required, "Album name"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
  end
  def create
    if link["audio_link"].start_with?("https://soundcloud.com/")
      obj = AudioLink.new(artist_audio_params)

      if obj.save
        @account.artist.audio_links << obj
        @account.artist.save

        LogHelper.log_account_changed_value(:audio, @account, obj.id)
        render json: obj, status: :created
      else
        render json: obj.errors, status: :unprocessable_entity
      end
    else
      render json: {errors: :FORBIDDEN_LINK}, status: :unprocessable_entity
    end
  end

  swagger_api :destroy do
    summary "Delete audio"
    param :path, :account_id, :integer, :required, "Account id"
    param :path, :id, :integer, :required, "Audio id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :unauthorized
    response :not_found
  end
  def destroy
    audio = @account.artist.audio_links.find(params[:id])
    audio.destroy

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

  def artist_audio_params
    params.permit(:audio_link, :song_name, :album_name)
  end
end
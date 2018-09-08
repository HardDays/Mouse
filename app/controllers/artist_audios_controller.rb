class ArtistAudiosController < ApplicationController
  before_action :authorize_account, only: [:index, :show]
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

  private
  def authorize_account
    @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])

    if @account == nil or @account.artist == nil
      render json: {error: "Access forbidden"}, status: :forbidden and return
    end
  end
end
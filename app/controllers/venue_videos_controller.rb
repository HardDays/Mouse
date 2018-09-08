class VenueVideosController < ApplicationController
  before_action :authorize_account, only: [:index, :show]
  swagger_controller :venue_videos, "Venue videos"

  swagger_api :index do
    summary "Get artist videos"
    param :path, :account_id, :integer, :required, "Artist account id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
  end
  def index
    videos = @account.venue.venue_video_links

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
    video = @account.venue.venue_video_links.find(params[:id])

    render json: video, status: :ok
  end

  private
  def authorize_account
    @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])

    if @account == nil or @account.venue == nil
      render json: {error: "Access forbidden"}, status: :forbidden and return
    end
  end
end
class VenueVideosController < ApplicationController
  before_action :authorize_account, only: [:create, :destroy]
  before_action :set_account, only: [:index, :show]
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

  swagger_api :create do
    summary "Add audio to venue"
    param :path, :account_id, :integer, :required, "Venue account id"
    param :form, :video_link, :string, :required, "Link to video"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
  end
  def create
    obj = VenueVideoLink.new(video_link: link)
    if obj.save
      @account.venue.venue_video_links << obj
      @account.venue.save

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
    video = @account.venue.venue_video_links.find(params[:id])
    video.destroy

    render status: :ok
  end


  private
  def set_account
    @account = Account.find(param[:account_id])
  end

  def authorize_account
    @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])

    if @account == nil or @account.venue == nil
      render json: {error: "Access forbidden"}, status: :forbidden and return
    end
  end
end
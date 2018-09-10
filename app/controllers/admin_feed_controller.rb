class AdminFeedController < ApplicationController
  before_action :authorize_admin
  swagger_controller :admin_feed, "AdminPanel"

  # GET /admin_feeds
  swagger_api :index do
    summary "Retrieve feed"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def index
    feed = AdminFeed.all.order(created_at: :desc)

    if params[:offset] == 0 or params[:offset] == nil and feed.exists?
      seen = AdminSeenFeed.new(admin_id: @admin.id, admin_feed_id: AdminFeed.last.id)
      seen.save
    end

    render json: feed.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  private
  def authorize_admin
    user = AuthorizeHelper.authorize(request)

    render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)
    @admin = user.admin
  end
end

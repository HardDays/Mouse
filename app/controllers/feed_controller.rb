class FeedController < ApplicationController
  before_action :authorize_account, except: :action_types
  swagger_controller :feed, "Feed"

  # GET action_types
  swagger_api :action_types do
    summary "Action types"
  end
  def action_types
    actions = []
    HistoryHelper::EVENT_ACTIONS.each do |action|
      if action == :update
        HistoryHelper::EVENT_FIELDS.each do |field|
          actions.push("#{action} #{field}")
        end
      else
        actions.push(action)
      end
    end

    render json: actions, status: :ok
  end

  # GET account/1/feeds
  swagger_api :index do
    summary "Account's feed"
    param :path, :account_id, :integer, :required, "Account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def index
    following = @account.following.pluck('id')
    likes = Like.where(account_id: following).joins(:event).as_json(feed: true)
    likes.each do |e|
      e[:type] = 'like'
      e[:action] = ''
    end

    event_updates = EventUpdate.left_joins(:event => :comments).where(
      :events => {creator_id: following, is_active: true}
    ).as_json(feed: true, user: @user)
    event_updates.each do |e|
      e[:type] = "event update"
      e[:action] = "#{e['action']} #{e['field']}"
      e.delete('field')
    end
    #
    @feed = likes.concat(event_updates).sort_by{|u| u[:created_at]}.reverse

    render json: @feed
  end


  private
  def authorize_account
    @user = AuthorizeHelper.authorize(request)
    @account = Account.find(params[:account_id])
    render status: :unauthorized if @user == nil or @account.user != @user
  end

  def authorize
    @user = AuthorizeHelper.authorize(request)
    return @user != nil
  end
end
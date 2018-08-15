class FeedItemsController < ApplicationController
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
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def index
    following = @account.following.pluck(:id)
    events_tickets = Ticket.where(id: FanTicket.where(account_id: @account.id).pluck(:ticket_id).uniq).pluck(:event_id)
    creator_events = Event.where(creator_id: following).pluck(:id)

    account_updates = AccountUpdate.where(account_id: following).pluck(:id)
    event_updates = EventUpdate.where(event_id: creator_events).or(EventUpdate.where(event_id: events_tickets)).pluck(:id)
    
    feed = FeedItem.where(account_update_id: account_updates).or(FeedItem.where(event_update_id: event_updates)).order(:created_at => :desc)
  
    # feed = FeedItem.all
    # feed = feed.left_joins(:account_update, :event_update => :event).where("account_updates.account_id IN (:query)", query: following)
    # .or(FeedItem.left_joins(:account_update, :event_update => :event).where(
    #   "events.creator_id IN (:query) and events.status=:status", query: following, status: Event.statuses["active"])
    # ).or(FeedItem.left_joins(:account_update, :event_update => :event).where(
    #   "events.id IN (NULL)", tickets: events_tickets)
    # )
    # .order(:created_at => :desc)
    # likes = Like.where(account_id: following).joins(:event).as_json(feed: true)
    # likes.each do |e|
    #   e[:type] = 'like'
    #   e[:action] = ''
    # end
    #
    # event_updates = EventUpdate.left_joins(:event => :comments).where(
    #   :events => {creator_id: following, is_active: true}
    # ).as_json(feed: true, user: @user)
    # event_updates.each do |e|
    #   e[:type] = "event update"
    #   e[:action] = "#{e['action']} #{e['field']}"
    #   e.delete('field')
    # end
    # #
    # @feed = likes.concat(event_updates).sort_by{|u| u[:created_at]}.reverse

    render json: feed.limit(params[:limit]).offset(params[:offset]), user: @user
  end


  private
  def authorize_account
    @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])

    if @account == nil
      render json: {error: "Access forbidden"}, status: :forbidden and return
    end

    @user = @account.user
  end

  def authorize
    @user = AuthorizeHelper.authorize(request)
    return @user != nil
  end
end
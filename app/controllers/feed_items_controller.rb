class FeedItemsController < ApplicationController
  before_action :authorize_account, except: :action_types
  swagger_controller :feed, "Feed"

  # GET action_types
  swagger_api :action_types do
    summary "Action types"
  end
  def action_types
    actions = []
    HistoryHelper::ACTIONS.each do |action|
      if action == :update
        HistoryHelper::FIELDS.each do |field|
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
    events_tickets = Ticket.where(
      id: FanTicket.where(account_id: @account.id).pluck(:ticket_id).uniq
    ).pluck(:event_id)
    creator_events = Event.where(creator_id: following, status: :active).pluck(:id)
    my_events = Event.where(creator_id: @account.id).pluck(:id)
    
    feed = FeedItem.where(account_id: following)
    if creator_events.count > 0
      feed = feed.or(
        FeedItem.where(event_id: creator_events)
      )
    end
    if events_tickets.count > 0
      feed = feed.or(
        FeedItem.where(event_id: events_tickets)
      )
    end
    feed = feed.where.not(event_id: my_events).order(:created_at => :desc)

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
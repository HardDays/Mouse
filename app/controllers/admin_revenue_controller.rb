class AdminRevenueController < ApplicationController
  before_action :authorize_admin
  swagger_controller :admin_revenue, "AdminPanel"

  # GET /admin/revenue
  swagger_api :index do
    summary "Get revenue by event"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def index
    events = Event.select(
      "events.*, sum(fan_tickets.price) as revenue"
    ).left_joins(:tickets => :fan_tickets).order(:date_from => :desc).group("events.id")

    render json: events.limit(params[:limit]).offset(params[:offset]),
           each_serializer: AdminEventsRevenueSerializer, status: :ok
  end

  # GET /admin/revenue/1
  swagger_api :show do
    summary "Get revenue by particular event"
    param :path, :id, :integer, :required, "Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def show
    event = Event.select(
      "events.*, sum(fan_tickets.price) as total_revenue"
    ).left_joins(:tickets => :fan_tickets).order(:date_from => :desc).group("events.id").find(params[:id])

    render json: event, serializer: AdminEventRevenueSerializer, status: :ok
  end

  # GET /admin/revenue/cities
  swagger_api :cities do
    summary "Get revenue by cities"
    param_list :query, :type, :string, :required, "Type of revenue", [:total, :sales]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def cities
    cities = FanTicket.select(
      "fans.address, sum(fan_tickets.price) as price"
    ).joins(account: :fan).group("fans.address").order('price')
    render json: {
      total: FanTicket.sum(:price),
      cities: cities.as_json(only: [:address, :price])
    }, status: :ok
  end

  # GET /admin/revenue/counts
  swagger_api :counts do
    summary "Get revenue counts"
    param_list :query, :type, :string, :required, "Type of revenue", [:total, :sales]
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def counts
    date = calculate_date(params[:type], params[:by])
    artist = calculate_artist(params[:type], params[:by])
    venue = calculate_venue(params[:type], params[:by])
    vr = calculate_vr(params[:type], params[:by])
    tickets = calculate_tickets(params[:type], params[:by])
    advertising = calculate_advertising(params[:type], params[:by])
    crowdfunding = calculate_crowdfunding(params[:type], params[:by])
    regular = calculate_regular(params[:type], params[:by])

    render json: {
      date: date,
      artist:artist,
      venue: venue,
      vr: vr,
      tickets: tickets,
      advertising: advertising,
      crowdfung: crowdfunding,
      regular:regular,
    }, status: :ok
  end

  # GET /admin/revenue/counts/date
  swagger_api :date do
    summary "Get revenue counts"
    param_list :query, :type, :string, :required, "Type of revenue", [:total, :sales]
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def date
    render json: calculate_date(params[:type], params[:by]), status: :ok
  end

  # GET /admin/revenue/counts/artist
  swagger_api :artist do
    summary "Get revenue counts"
    param_list :query, :type, :string, :required, "Type of revenue", [:total, :sales]
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def artist
    render json: calculate_artist(params[:type], params[:by]), status: :ok
  end

  # GET /admin/revenue/venue
  swagger_api :venue do
    summary "Get revenue counts"
    param_list :query, :type, :string, :required, "Type of revenue", [:total, :sales]
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def venue
    render json: calculate_venue(params[:type], params[:by]), status: :ok
  end

  # GET /admin/revenue/counts/vr
  swagger_api :vr do
    summary "Get revenue counts"
    param_list :query, :type, :string, :required, "Type of revenue", [:total, :sales]
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def vr
    render json: calculate_vr(params[:type], params[:by]), status: :ok
  end

  # GET /admin/revenue/counts/tickets
  swagger_api :tickets do
    summary "Get revenue counts"
    param_list :query, :type, :string, :required, "Type of revenue", [:total, :sales]
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def tickets
    render json: calculate_tickets(params[:type], params[:by]), status: :ok
  end

  # GET /admin/revenue/counts/advertising
  swagger_api :advertising do
    summary "Get revenue counts"
    param_list :query, :type, :string, :required, "Type of revenue", [:total, :sales]
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def advertising
    render json: calculate_advertising(params[:type], params[:by]), status: :ok
  end

  # GET /admin/revenue/counts/funding
  swagger_api :funding do
    summary "Get revenue counts"
    param_list :query, :type, :string, :required, "Type of revenue", [:total, :sales]
    param_list :query, :funding_type, :string, :required, "Type of revenue", [:crowdfunding, :regular]
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def funding
    if params[:funding_type] == 'crowdfunding'
      render json: calculate_crowdfunding(params[:type], params[:by]), status: :ok
    else
      render json: calculate_regular(params[:type], params[:by]), status: :ok
    end
  end

  private
  def authorize_admin
    user = AuthorizeHelper.authorize(request)

    render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)
    @admin = user.admin
  end

  def filter_and_count(entity, type, by, sum)
    if by
      if by == 'day'
        entity.where(created_at: DateTime.now)
      elsif by == 'week'
        entity.where(created_at: 1.week.ago..DateTime.now)
      elsif by == 'month'
        entity.where(created_at: 1.month.ago..DateTime.now)
      elsif by == 'year'
        entity.where(created_at: 1.year.ago..DateTime.now)
      end
    end
    entity = entity.sum(sum)

    if type == 'total'
      entity = entity * 0.1
    end

    return entity
  end

  def calculate_date(type, by)
    date = FanTicket.all
    return filter_and_count(date, type, by, :price)
  end

  def calculate_artist(type, by)
    artist = Event.joins(
      :artist_events => :agreed_date_time_and_price
    ).where(artist_events: {status: 'owner_accepted'})

    return filter_and_count(artist, type, by, 'agreed_date_time_and_prices.price')
  end

  def calculate_venue(type, by)
    venue = Event.joins(
      :venue_events => :agreed_date_time_and_price
    ).where(venue_events: {status: 'owner_accepted'})

    return filter_and_count(venue, type, by, 'agreed_date_time_and_prices.price')
  end

  def calculate_vr(type, by)
    vr = Ticket.joins(:fan_tickets, :tickets_type).where(
      tickets: {tickets_types: {name: 'vr'}, is_promotional: false})

    return filter_and_count(vr, type, by, 'fan_tickets.price')
  end

  def calculate_tickets(type, by)
    ticket = Ticket.joins(:fan_tickets, :tickets_type).where(
      tickets: {tickets_types: {name: 'in_person'}, is_promotional: false})

    return filter_and_count(ticket, type, by, 'fan_tickets.price')
  end

  def calculate_advertising(type, by)
    advertising = Ticket.joins(:fan_tickets).where(
      tickets: {is_promotional: true}
    )

    return filter_and_count(advertising, type, by, 'fan_tickets.price')
  end

  def calculate_crowdfunding(type, by)
    crowdfunding = FanTicket.joins(:ticket => :event).where(events: {is_crowdfunding_event: true})

    return filter_and_count(crowdfunding, type, by, 'fan_tickets.price')
  end

  def calculate_regular(type, by)
    regular = FanTicket.joins(:ticket => :event).where(events: {is_crowdfunding_event: false})

    return filter_and_count(regular, type, by, 'fan_tickets.price')
  end
end
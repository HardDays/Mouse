class AdminEventsController < ApplicationController
  before_action :authorize_admin
  swagger_controller :admin, "AdminPanel"

  # GET /admin/events/new_count
  swagger_api :new_count do
    summary "Get number of new events added"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def new_count
    render json: Event.where(status: 'just_added').count, status: :ok
  end

  # GET /admin/events/new_status
  swagger_api :new_status do
    summary "Get events analytics"
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def new_status
    success = Event.left_joins(:tickets => :fan_tickets).where(
      "events.funding_to <= :query", query: DateTime.now
    ).group("events.id").having(
      "sum(fan_tickets.price) >= events.funding_goal").pluck("COUNT(events.id)")[0].to_i

    failed = Event.left_joins(:tickets => :fan_tickets).where(
      "events.funding_to <= :query", query: DateTime.now
    ).group("events.id").having(
      "sum(fan_tickets.price) >= events.funding_goal").pluck("COUNT(events.id)")[0].to_i

    render json: {
      all: Event.count,
      pending: Event.where("events.funding_to > :query", query: DateTime.now).count,
      successful: success,
      failed: failed,
    }, status: :ok
  end

  # GET /admin/events/count
  swagger_api :counts do
    summary "Get events analytics"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def counts
    success = Event.left_joins(:tickets => :fan_tickets).where(
      "events.funding_to <= :query", query: DateTime.now
    ).group("events.id").having(
      "sum(fan_tickets.price) >= events.funding_goal").pluck("COUNT(events.id)")[0].to_i

    failed = Event.left_joins(:tickets => :fan_tickets).where(
      "events.funding_to <= :query", query: DateTime.now
    ).group("events.id").having(
      "sum(fan_tickets.price) >= events.funding_goal").pluck("COUNT(events.id)")[0].to_i

    render json: {
      all: Event.count,
      successful: success,
      failed: failed
    }, status: :ok
  end

  # GET /admin/events/individual
  swagger_api :individual do
    summary "Get top 5 events analytics"
    param :query, :text, :string, :optional, "Search text"
    param :query, :event_type, :string, :optional, "Array of type of events [:viewed, :liked, :commented, :crowdfund, :regular, :successful, :pending, :failed]"
    param_list :query, :sort_by, :string, :optional, "Sort by", [:name, :date]
    param :query, :limit, :integer, :optional, 'Limit'
    param :query, :offset, :integer, :optional, 'Offset'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def individual
    events_base = Event.left_joins(:likes, :comments).select('events.*, count(likes.id) as likes, count(comments.id) as comments')
    events = events_base

    if params[:text] or not (['crowdfund', 'regular', 'successful', 'pending', 'failed'] & params[:event_type].to_a).empty?
      events = events.where("0=1")
    end

    if params[:text]
      events = events.where("events.name ILIKE :query", query: "%#{params[:text]}%")
    end

    if params[:event_type]
      params[:event_type].each do |type|
        if type == 'crowdfund'
          events = events.or(events_base.where(is_crowdfunding_event: true))
        elsif type == 'regular'
          events = events.or(events_base.where(is_crowdfunding_event: false))
        elsif type == 'successful'
          events = events.or(events_base.where(status: 'approved'))
        elsif type == 'pending'
          events = events.or(events_base.where(status: 'pending'))
        elsif type == 'failed'
          events = events.or(events_base.where(status: 'denied'))
        end
      end

      params[:event_type].each do |type|
        # если сначала есть ордер, то они ругаются((((
        if type == 'viewed'
          events = events.order(:views => :desc)
        elsif type == 'liked'
          events = events.order("likes DESC")
        elsif type == 'commented'
          events = events.order("comments DESC")
        end
      end
    end

    if params[:sort_by] == 'name'
      events = events.order(:name)
    elsif params[:sort_by] == 'date'
      events = events.order(:date_from => :desc)
    end

    render json: events.group('events.id').limit(params[:limit]).offset(params[:offset]),
           each_serializer: AdminEventsAnalyticSerializer, status: :ok
  end

  # GET admin/events/requests
  swagger_api :event_requests do
    summary "Get all event requests"
    param :query, :text, :string, :optional, "Search text"
    param_list :query, :event_type, :string, :optional, "Type of events", [:all, :crowdfunding, :regular]
    param_list :query, :status, :string, :optional, "Event status", [:just_added, :pending, :approved, :denied, :active, :inactive]
    param :query, :limit, :integer, :optional, 'Limit'
    param :query, :offset, :integer, :optional, 'Offset'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def event_requests
    events = Event.all.order(:created_at => :desc)

    if params[:text]
      events = events.where("events.name ILIKE :query", query: "%#{params[:text]}%")
    end

    if params[:event_type] == 'crowdfunding'
      events = events.where(is_crowdfunding_event: true)
    elsif params[:event_type] == 'regular'
      events = events.where(is_crowdfunding_event: false)
    end

    if params[:status]
      events = events.where(status: params[:status])
    end

    render json: events.limit(params[:limit]).offset(params[:offset]),
           each_serializer: AdminEventSerializer,
           status: :ok
  end

  # GET /admin/events/graph
  swagger_api :graph do
    summary "Get events info for graph"
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def graph
    if params[:by] == 'all'
      dates = Event.pluck("min(created_at), max(created_at)").first
      diff = Time.diff(dates[0], dates[1])
      if diff[:month] > 0
        new_step = 'year'
      elsif diff[:week] > 0
        new_step = 'month'
      elsif diff[:day] > 0
        new_step = 'week'
      else
        new_step = 'day'
      end

      axis = GraphHelper.custom_axis(new_step, dates)
      dates_range = dates[0]..dates[1]
      params[:by] = new_step
    else
      axis = GraphHelper.axis(params[:by])
      dates_range = GraphHelper.sql_date_range(params[:by])
    end

    events = Event.where(
      created_at: dates_range
    ).order(:is_crowdfunding_event, :created_at).to_a.group_by(
      &:is_crowdfunding_event
    ).each_with_object({}) {
      |(k, v), h| h[k] = v.group_by{ |e| e.created_at.strftime(GraphHelper.type_str(params[:by])) }
    }.each { |(k, h)|
      h.each { |m, v|
        h[m] = v.count
      }
    }

    render json: {
      axis: axis,
      crowdfunding: events[true],
      regular: events[false],
    }, status: :ok
  end

  # GET admin/events/1
  swagger_api :get_event do
    summary "Retrieve event by id"
    param :path, :id, :integer, :required, "Event id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def get_event
    render json: Event.find(params[:id]), extended: true, status: :ok
  end

  # POST admin/events/<id>/approve
  swagger_api :approve do
    summary "Approve event"
    param :path, :id, :integer, :required, "Event id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
    response :method_not_allowed
  end
  def approve
    event = Event.find(params[:id])

    if event and ['just_added', 'pending'].include?(event.status)
      event.update(status: 'approved')
      event.update(processed_by: @admin.id)
      render status: :ok
    else
      render status: :method_not_allowed
    end
  end

  # POST admin/events/<id>/deny
  swagger_api :deny do
    summary "Deny event"
    param :path, :id, :integer, :required, "Event id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
    response :method_not_allowed
  end
  def deny
    event = Event.find(params[:id])

    if event and ['just_added', 'pending', 'approved'].include?(event.status)
      event.update(status: 'denied')
      event.update(processed_by: @admin.id)
      render status: :ok
    else
      render status: :method_not_allowed
    end
  end

  # DELETE admin/accounts/<id>
  swagger_api :destroy do
    summary "Delete account"
    param :path, :id, :integer, :required, "Account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :ok
  end
  def destroy
    event = Event.find(params[:id])
    event.destroy

    render status: :ok
  end

  private
  def authorize_admin
    user = AuthorizeHelper.authorize(request)

    render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)
    @admin = user.admin
  end
end
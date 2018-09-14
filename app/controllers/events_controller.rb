class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy, :launch, :set_inactive, :analytics,
                                   :click, :view, :verify, :set_date, :backers, :get_updates]
  before_action :authorize_user, only: [:show]
  before_action :authorize_account, only: [:my, :create]
  before_action :authorize_creator, only: [:update, :destroy, :launch, :set_inactive, :verify, :set_date]
  swagger_controller :events, "Events"

  # GET /events
  swagger_api :index do
    summary "Retrieve list of events"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    @events = Event.available.where(status: 'active')

    render json: @events.limit(params[:limit]).offset(params[:offset]).order(:date_from, :funding_from), status: :ok
  end

  # GET /events/1
  swagger_api :show do
    summary "Retrieve event by id"
    param :path, :id, :integer, :required, "Event id"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
  end
  def show
    render json: @event, extended: true, user: @user, status: :ok
  end

  # GET /events/1/backers
  swagger_api :backers do
    summary "Retrieve list of event backers"
    param :path, :id, :integer, :required, "Event id"
    param :query, :text, :string, :optional, "Text to search"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    # param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
  end
  def backers
    backers = Account.joins(fan_tickets: :ticket).where(tickets: {event_id: params[:id]}).distinct

    if params[:text]
      backers = backers.search_fan_fullname(params[:text])
    end

    backers = backers.order(created_at: :desc)
    render json: backers.limit(params[:limit]).offset(params[:offset]), backers: true, status: :ok
  end

  # GET /events/1/updates
  swagger_api :get_updates do
    summary "Retrieve event updates by id"
    param :path, :id, :integer, :required, "Event id"
    response :ok
  end
  def get_updates
    event_updates = @event.feed_items.select(
      :action, :field, :created_at).as_json(only: [:action, :field, :created_at]).each {|e| e[:type] = "event"}

    venue_updates = @event.venue.account.feed_items.select(
      :action, :field, :created_at).as_json(only: [:action, :field, :created_at]).each {|e| e[:type] = "venue"}

    artists_ids = @event.artist_events.where(status: 'accepted').pluck(:artist_id)
    artists_updates = FeedItem.where(account_id: artists_ids).select(
      :action, :field, :created_at).as_json(only: [:action, :field, :created_at]).each {|e| e[:type] = "artist"}

    event_updates.concat(artists_updates).concat(venue_updates).sort_by{|u| u[:created_at]}
    render json: event_updates
  end

  # POST /events
  swagger_api :create do
    summary 'Create event'
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :form, :name, :string, :optional, "Event name"
    param :form, :image_base64, :string, :optional, "Image base64 string"
    param :form, :image, :file, :optional, "Image"
    param :form, :video_link, :string, :optional, "Event video"
    param :form, :tagline, :string, :optional, "Tagline"
    param :form, :hashtag, :string, :optional, "Hashtag"
    param :form, :description, :string, :optional, "Short description"
    param :form, :funding_from, :datetime, :optional, "Finding duration from"
    param :form, :funding_to, :datetime, :optional, "Finding duration to"
    param :form, :funding_goal, :integer, :optional, "Funding goal"
    param :form, :total, :integer, :optional, "Total"
    param_list :form, :currency, :integer, :required, "Preferred currency format", [:RUB, :USD, :EUR]
    param :form, :updates_available, :boolean, :optional, "Is updates available"
    param :form, :comments_available, :boolean, :optional, "Is comments available"
    param :form, :date_from, :datetime, :optional, "Date from"
    param :form, :date_to, :datetime, :optional, "Date to"
    param_list :form, :event_season, :integer, :optional, "Event month range", ['spring', 'summer', 'autumn', 'winter']
    param :form, :event_year, :integer, :optional, "Event year range"
    param :form, :event_length, :integer, :optional, "Event length in hours"
    param_list :form, :event_time, :integer, :optional, "Event time", ['morning', 'afternoon', 'evening']
    param :form, :is_crowdfunding_event, :boolean, :optional, "Is crowdfunding event"
    param :form, :city_lat, :float, :optional, "Event city lat"
    param :form, :city_lng, :float, :optional, "Event city lng"
    param :form, :address, :string, :optional, "Event address"
    param :form, :artists_number, :integer, :optional, "Event artists number"
    param :form, :additional_cost, :integer, :optional, "Additional cost"
    param :form, :family_and_friends_amount, :integer, :optional, "Family and friends amount"
    param :form, :genres, :string, :optional, "Genres list ['pop', 'rock', ...]"
    param :form, :collaborators, :string, :optional, "Collaborators list [1,2,3, ...]"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :unauthorized
  end
  def create
    @event = Event.new(event_params)
    @event.creator = @account

    if @event.save
      set_image
      set_base64_image
      set_genres
      set_collaborators

      render json: @event, status: :created
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /events/1
  swagger_api :update do
    summary 'Update event'
    param :path, :id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :form, :image_base64, :string, :optional, "Image base64 string"
    param :form, :image, :file, :optional, "Image"
    param :form, :video_link, :string, :optional, "Event video"
    param :form, :name, :string, :optional, "Event name"
    param :form, :tagline, :string, :optional, "Tagline"
    param :form, :hashtag, :string, :optional, "Hashtag"
    param :form, :description, :string, :optional, "Short description"
    param :form, :funding_from, :datetime, :optional, "Finding duration from"
    param :form, :funding_to, :datetime, :optional, "Finding duration to"
    param :form, :funding_goal, :integer, :optional, "Funding goal"
    param :form, :total, :integer, :optional, "Total"
    param_list :form, :currency, :integer, :required, "Preferred currency format", [:RUB, :USD, :EUR]
    param :form, :updates_available, :boolean, :optional, "Is updates available"
    param :form, :comments_available, :boolean, :optional, "Is comments available"
    param :form, :date_from, :datetime, :optional, "Date from"
    param :form, :date_to, :datetime, :optional, "Date to"
    param_list :form, :event_season, :integer, :optional, "Event month range", ['spring', 'summer', 'autumn', 'winter']
    param :form, :event_year, :integer, :optional, "Event year range"
    param :form, :event_length, :integer, :optional, "Event length in hours"
    param_list :form, :event_time, :integer, :optional, "Event time", ['morning', 'afternoon', 'evening']
    param :form, :is_crowdfunding_event, :boolean, :optional, "Is crowdfunding event"
    param :form, :city_lat, :float, :optional, "Event city lat"
    param :form, :city_lng, :float, :optional, "Event city lng"
    param :form, :address, :string, :optional, "Event address"
    param :form, :artists_number, :integer, :optional, "Event artists number"
    param :form, :additional_cost, :integer, :optional, "Additional cost"
    param :form, :family_and_friends_amount, :integer, :optional, "Family and friends amount"
    param :form, :genres, :string, :optional, "Genres list ['pop', 'rock', ...]"
    param :form, :collaborators, :string, :optional, "Collaborators list [1,2,3, ...]"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :unauthorized
  end
  def update
    set_image
    set_base64_image
    set_genres
    set_collaborators

    forbidden = check_params

    upd_params = @event.is_launched? ? active_event_params : event_params

    @event.assign_attributes(upd_params)
    changed = @event.changed

    if not forbidden and @event.update(upd_params)
      if @event.is_launched?
        changed.each do |param|
          if HistoryHelper::EVENT_FIELDS.include?(param.to_sym)
            feed = FeedItem.new(
              action: :update,
              updated_by: @account.id,
              event_id: @event.id,
              field: param,
              value: params[param]
            )
            feed.save
          end
        end
      end
      render json: @event, extended: true, user: @user, status: :ok
    else
      render json: @event.errors, status: (forbidden ? forbidden : :unprocessable_entity)
    end
  end

  # GET /event/1/analytics
  swagger_api :analytics do
    summary "Get analytic data"
    param :path, :id, :integer, :required, "Event id"
    response :unauthorized
    response :not_found
  end
  def analytics
    render json: @event, analytics: true, status: :ok
  end

  # POST /events/1/set_date
  swagger_api :set_date do
    summary "Set event's exact date"
    param :path, :id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :form, :exact_date_from, :integer, :required, "Exact start date"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def set_date
    date = DateTime.parse(params[:exact_date_from])
    valid = date_valid?(date)

    if valid and ["denied", "just_added", "pending", "approved"].include?(@event.status)
      @event.exact_date_from = params[:exact_date_from]
      @event.exact_date_to = DateTime.parse(params[:exact_date_from]) + @event.event_length.hours
      @event.save

      render json: @event, status: :ok
    elsif valid
      render status: :forbidden
    end
  end

  # POST /events/1/verify
  swagger_api :verify do
    summary "Send event to check"
    param :path, :id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def verify
    if ["declined", "just_added"].include?(@event.status)
      @event.status = "pending"
      @event.save

      render status: :ok
    end
  end

  # POST /events/1/launch
  swagger_api :launch do
    summary "Set event active"
    param :path, :id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def launch
    if @event.tickets.empty?
      render json: {errors: :NO_TICKETS}, status: :forbidden and return
    end

    if @event.artist_events.where(artist_events: {status: ArtistEvent.statuses["owner_accepted"]}).empty?
      render json: {errors: :NO_ARTISTS}, status: :forbidden and return
    end

    if @event.venue == nil
      render json: {errors: :NO_VENUE}, status: :forbidden and return
    end

    if @event.exact_date_from == nil
      render json: {errors: :NO_EXACT_DATE}, status: :forbidden and return
    end

    if ["approved", "inactive"].include?(@event.status)
      @event.status = "active"
      @event.save

      feed = FeedItem.new(
        action: :launch_event,
        updated_by: @account.id,
        event_id: @event.id,
      )
      feed.save

      render status: :ok
    end
  end

  # POST /events/1/deactivate
  swagger_api :set_inactive do
    summary "Set event inactive"
    param :path, :id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def set_inactive
    if @event.status == "active"
      @event.status = "inactive"
      @event.save

      render status: :ok
    end
  end

  # GET /events/1/click
  swagger_api :click do
    summary "Add click to event"
    param :path, :id, :integer, :required, "Event id"
    response :not_found
  end
  def click
    @event.clicks += 1
    @event.save

    render status: :ok
  end

  # GET /events/1/view
  swagger_api :view do
    summary "Add view to event"
    param :path, :id, :integer, :required, "Event id"
    response :not_found
  end
  def view
    @event.views += 1
    @event.save

    render status: :ok
  end

  # GET /events/my
  swagger_api :my do
    summary "Get my events"
    param :query, :account_id, :integer, :required, "Account id"
    param :query, :text, :string, :optional, "Text to search"
    param :query, :is_active, :boolean, :optional, "Search only active events"
    param :query, :location, :string, :optional, "Address"
    param :query, :lat, :float, :optional, "Latitude (lng and distance must be present)"
    param :query, :lng, :float, :optional, "Longitude (lat and distance must be present)"
    param :query, :distance, :integer, :optional, "Artist/Venue address max distance"
    param :query, :units, :string, :optional, "Artist/Venue distance units of search 'km' or 'mi'"
    param :query, :from_date, :datetime, :optional, "Left bound of date (to_date must be presenty)"
    param :query, :to_date, :datetime, :optional, "Right bound of date (from_date must be present)"
    param :query, :genres, :string, :optional, "Genres list ['pop', 'rock', ...]"
    param :query, :ticket_types, :string, :optional, "Array of ticket types ['in_person', 'vip']"
    param :query, :size, :string, :optional, "Event's venue type of space ('night_club'|'concert_hall'|...)"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, "Auth token"
    response :unauthorized
  end
  def my
    @events = Event.available.get_my(@account).search(params[:text])
    search_active
    search_genre
    search_location
    search_distance
    search_date
    search_ticket_types
    search_type_of_space

    render json: @events.distinct.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # DELETE /events/1
  swagger_api :destroy do
    summary "Destroy event by id"
    param :path, :id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Authorized account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def destroy
    @event.destroy
    render status: :ok
  end

  # GET /events/search
  swagger_api :search do
    summary "Search for event"
    param :query, :text, :string, :optional, "Text to search"
    param :query, :location, :string, :optional, "Address"
    param :query, :city, :string, :optional, "City"
    param :query, :country, :string, :optional, "Country"
    param :query, :lat, :float, :optional, "Latitude (lng and distance must be present)"
    param :query, :lng, :float, :optional, "Longitude (lat and distance must be present)"
    param :query, :distance, :integer, :optional, "Artist/Venue address max distance"
    param :query, :units, :string, :optional, "Artist/Venue distance units of search 'km' or 'mi'"
    param :query, :from_date, :datetime, :optional, "Left bound of date (to_date must be presenty)"
    param :query, :to_date, :datetime, :optional, "Right bound of date (from_date must be present)"
    param :query, :genres, :string, :optional, "Genres list ['pop', 'rock', ...]"
    param :query, :ticket_types, :string, :optional, "Array of ticket types ['in_person', 'vip']"
    param :query, :size, :string, :optional, "Event's venue type of space ('night_club'|'concert_hall'|...)"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def search
    @events = Event.searchable.search(params[:text])
    search_genre
    search_city
    search_country
    search_location
    search_distance
    search_ticket_types
    search_type_of_space
    search_date
    # TODO: fix
    search_only_my

    render json: @events.distinct.limit(params[:limit]).offset(params[:offset]).order("events.exact_date_from, events.funding_from"), search: true, status: :ok
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    #TODO: отрефакторить как-нибудь
    def authorize_account
      @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])

      if @account == nil
        render json: {error: "Access forbidden"}, status: :forbidden and return
      end
    end

    def authorize_creator
      @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])

      if @account == nil
        render json: {error: "Access forbidden"}, status: :forbidden and return
      end

      @creator = Event.find(params[:id]).creator
      render status: :unauthorized if @creator != @account
    end

    def set_image
      if params[:image]
        image = Image.new(base64: Base64.encode64(File.read(params[:image].path)))
        image.save
        @event.image = image
        @event.images << image
        @event.save

        if @event.status == "active"
          feed = FeedItem.new(
            action: :update,
            updated_by: @account.id,
            event_id: @event.id,
            field: :image,
            value: image.id
          )
          feed.save
        end
      end
    end

    def set_base64_image
      if params[:image_base64] and (@event.image == nil or params[:image_base64] != @event.image.base64)
        image = Image.new(base64: params[:image_base64])
        image.save
        @event.image = image
        @event.images << image
        @event.save

        if @event.status == "active"
          feed = FeedItem.new(
            action: :update,
            updated_by: @account.id,
            event_id: @event.id,
            field: :image,
            value: image.id
          )
          feed.save
        end
      end
    end

    def set_genres
      if params[:genres]
        @event.genres.clear
        params[:genres].each do |genre|
          obj = EventGenre.new(genre: genre)
          obj.save
          @event.genres << obj
          @event.save
        end
      end
    end

    def set_collaborators
      if params[:collaborators]
        @event.collaborators.clear
        params[:collaborators].each do |collaborator|
          obj = Account.find(collaborator)
          @event.collaborators << obj
          @event.save
        end
      end
    end

    def search_active
      if ActiveRecord::Type::Boolean.new.cast(params[:is_active])
        @events = @events.where(status: "active")
      elsif ActiveRecord::Type::Boolean.new.cast(params[:is_active]) == false
        @events = @events.where.not(status: "active")
      end
    end

    def search_date
       if params[:from_date]
         @events = @events.where("events.exact_date_from >= :date",
                                 {:date => DateTime.parse(params[:from_date])})
       end
       if params[:to_date]
         @events = @events.where("events.exact_date_to <= :date",
                                 {:date => DateTime.parse(params[:to_date])})
       end
    end

    def search_location
      if params[:location]
        @events = @events.near(params[:location])
      end
    end

    def search_distance
      if params[:distance] and params[:lng] and params[:lat] and params[:units]
        @events = @events.near([params[:lat], params[:lng]], params[:distance], units: params[:units])
      else
        @vens = @events.near([params[:lat], params[:lng]], params[:distance])
      end
    end

    def search_genre
      if params[:genres]
        genres = []
        params[:genres].each do |genre|
          genres.append(EventGenre.genres[genre])
        end
        @events = @events.joins(:genres).where(:event_genres => {genre: genres})
      end
    end

    def search_country
      if params[:country]
        @events = @events.where("lower(events.country) = ?", params[:country].downcase.strip)
      end
    end

    def search_city
      if params[:city]
        @events = @events.where("lower(events.city) = ?", params[:city].downcase.strip)
      end
    end

    def search_ticket_types
      if params[:ticket_types]
        types = []
        params[:ticket_types].each do |type|
          types.append(TicketsType.names[type])
        end
        @events = @events.joins(:tickets => :tickets_type).where(:tickets_types => {name: types})
      end
    end

    def search_type_of_space
      if params[:size]
        @events = @events.joins(
          :venue => :public_venue
        ).where(public_venues: {type_of_space: PublicVenue.type_of_spaces[params[:size]]})
      end
    end

    def search_only_my
      if params[:only_my]
        @events = @events.where(creator_id: params[:account_id])
      end
    end

    def check_params
      if (params[:date_from] or params[:date_to]) and @event.is_crowdfunding_event
        founded = @event.tickets.joins(:fan_tickets).sum("fan_tickets.price")

        return :forbidden if founded >= @event.funding_goal
      end

      if (params[:address] or params[:city_lat] or params[:city_lng]) and @event.venue_id != nil
        return :forbidden
      end
    end

  def date_valid?(date)
    unless @event.date_from <= date and date <= (@event.date_to - @event.event_length.hours)
      render json: {errors: :INVALID_DATE}, status: :unprocessable_entity
      return false
    end

    true
  end

  def active_event_params
    params.permit(:description)
  end

  def event_params
      params.permit(:name, :tagline, :hashtag, :description, :funding_from, :funding_to,
                    :funding_goal, :comments_available, :updates_available, :date_from, :date_to,
                    :event_season, :event_year, :event_length, :event_time, :is_crowdfunding_event,
                    :city_lat, :city_lng, :address, :artists_number, :video_link, :additional_cost,
                    :family_and_friends_amount, :currency, :total)
  end

  def authorize
      @user = AuthorizeHelper.authorize(request)
      return @user != nil
  end

  def authorize_user
      if request.headers['Authorization']
        @user = AuthorizeHelper.authorize(request)
        return @user
      end
  end
end

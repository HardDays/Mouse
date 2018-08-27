class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy, :launch, :set_inactive, :analytics,
                                   :click, :view, :get_updates, :verify]
  before_action :authorize_account, only: [:my, :create]
  before_action :authorize_creator, only: [:update, :destroy, :launch, :set_inactive, :verify]
  swagger_controller :events, "Events"

  # GET /events
  swagger_api :index do
    summary "Retrieve list of events"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    @events = Event.where(is_active: true)

    render json: @events.limit(params[:limit]).offset(params[:offset]).order(:date_from, :funding_from), status: :ok
  end

  # GET /events/1
  swagger_api :show do
    summary "Retrieve event by id"
    param :path, :id, :integer, :required, "Event id"
    response :ok
  end
  def show  
    render json: @event, extended: true, status: :ok
  end

  # GET /events/1/updates
  swagger_api :get_updates do
    summary "Retrieve event updates by id"
    param :path, :id, :integer, :required, "Event id"
    response :ok
  end
  def get_updates
    event_updates = @event.event_updates.select(:action, :field, :created_at).as_json.each {|e| e[:type] = "event"}
    venue_updates = @event.venue.account_updates.select(
      :action, :field, :created_at).as_json.each {|e| e[:type] = "venue"}

    artists_ids = @event.artist_events.where(status: 'accepted').pluck(:artist_id)
    artists_updates = AccountUpdate.where(account_id: artists_ids).select(
      :action, :field, :created_at).as_json.each {|e| e[:type] = "artist"}

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
    if not forbidden and @event.update(event_params)

      log_update
      render json: @event, extended: true, status: :ok
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
    if ["approved", "inactive"].include?(@event.status)
      @event.status = "active"
      @event.save

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
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, "Auth token"
    response :unauthorized
  end
  def my
    @events = Event.get_my(@account)

    render json: @events.limit(params[:limit]).offset(params[:offset]), status: :ok
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
    param :query, :is_active, :boolean, :optional, "Search only active events"
    param :query, :location, :string, :optional, "Address"
    param :query, :lat, :float, :optional, "Latitude (lng and distance must be present)"
    param :query, :lng, :float, :optional, "Longitude (lat and distance must be present)"
    param :query, :distance, :float, :optional, "Radius in km (lat, lng must be present)"
    param :query, :from_date, :datetime, :optional, "Left bound of date (to_date must be presenty)"
    param :query, :to_date, :datetime, :optional, "Right bound of date (from_date must be present)"
    param :query, :genres, :string, :optional, "Genres list ['pop', 'rock', ...]"
    param :query, :ticket_types, :string, :optional, "Array of ticket types ['in_person', 'vip']"
    param :query, :size, :string, :optional, "Event's venue type of space ('night_club'|'concert_hall'|...)"
    param :query, :only_my, :boolean, :optional, "Search only in created by account events"
    param :query, :account_id, :integer, :optional, "Account id (required if :only_my parameter set True)"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def search
    @events = Event.search(params[:text])
    search_active
    search_genre
    search_location
    search_distance
    search_ticket_types
    search_type_of_space
    search_date
    search_only_my

    render json: @events.distinct.limit(params[:limit]).offset(params[:offset]).order("events.date_from, events.funding_from"), search: true, status: :ok
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    #TODO: отрефакторить как-нибудь
    def authorize_account
      @user = AuthorizeHelper.authorize(request)
      @account = Account.find(params[:account_id])
      render status: :unauthorized if @user == nil or @account.user != @user
    end

    def authorize_creator
      @user = AuthorizeHelper.authorize(request)
      @account = Account.find(params[:account_id])
      render status: :unauthorized and return if @user == nil or @account.user != @user

      @creator = Event.find(params[:id]).creator
      render status: :unauthorized if @creator != @account or @creator.user != @user
    end

    def set_image
      if params[:image]
        image = Image.new(base64: Base64.encode64(File.read(params[:image].path)))
        image.save
        @event.image = image
        @event.images << image
        @event.save
      end
    end

    def set_base64_image
      if params[:image_base64]
        image = Image.new(base64: params[:image_base64])
        image.save
        @event.image = image
        @event.images << image
        @event.save
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
      if params[:is_active]
        @events = @events.where(is_active: params[:is_active])
      end
    end

    def search_date
       if params[:from_date]
         @events = @events.where("events.date_from >= :date",
                                 {:date => DateTime.parse(params[:from_date])})
       end
       if params[:to_date]
         @events = @events.where("events.date_to <= :date",
                                 {:date => DateTime.parse(params[:to_date])})
       end
    end

    def search_location
      if params[:location]
        @events = @events.near(params[:location])
      end
    end

    def search_distance
      if params[:distance] and params[:lng] and params[:lat]
        @events = @events.near([params[:lat], params[:lng]], params[:distance])
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
          :venue => {venue: :public_venue}
        ).where(public_venues: {type_of_space: PublicVenue.type_of_spaces[params[:size]]})
      end
    end

    def search_only_my
      if params[:only_my]
        @events = @events.where(creator_id: params[:account_id])
      end
    end

    def log_update
      params.each do |param|
        if HistoryHelper::EVENT_FIELDS.include?(param.to_sym)
          action = EventUpdate.new(action: :update, updated_by: @account.id, event_id: @event.id, field: param)
          action.save
        end
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

  def send_mouse_request(account)
    request_message = RequestMessage.new(request_message_params)
    request_message.save

    @event.request_messages << request_message
    account.request_messages << request_message
  end

  def request_message_params
    params.permit(:time_frame, :is_personal, :estimated_price, :message)
  end

    def event_params
      params.permit(:name, :tagline, :hashtag, :description, :funding_from, :funding_to,
                    :funding_goal, :comments_available, :updates_available, :date_from, :date_to,
                    :event_season, :event_year, :event_length, :event_time, :is_crowdfunding_event,
                    :city_lat, :city_lng, :address, :artists_number, :video_link, :additional_cost,
                    :family_and_friends_amount)
    end

    def authorize
      @user = AuthorizeHelper.authorize(request)
      return @user != nil
    end

    def authorize_user
      render status: :forbidden if not authorize
    end
end

class FanTicketsController < ApplicationController
  before_action :authorize_account, only: [:create, :create_many, :destroy]
  before_action :set_ticket, only: [:create, :create_many]
  before_action :check_ticket, only: [:create, :create_many]
  before_action :set_fan_ticket, only: [:show, :destroy]
  swagger_controller :fan_ticket, "FanTickets"

  # GET /fan_tickets
  swagger_api :index do
    summary "Retrieve list of fan tickets"
    param :query, :account_id, :integer, :required, "Fan account id"
    param_list :query, :time, :string, :required, "Tickets time frame", ['current', 'past']
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def index
    if params[:time] == 'current'
      @events = Event.joins(:tickets => :fan_tickets).where(
        fan_tickets: {account_id: params[:account_id]}
      ).where(
        "(events.date_to >= :date OR events.date_to IS NULL)", {:date => DateTime.now}
      ).group("events.id")
    else
      @events = Event.joins(:tickets => :fan_tickets).where(
        fan_tickets: {account_id: params[:account_id]}
      ).where(
        "events.date_to < :date", {:date => DateTime.now}
      ).group("events.id")

    end
    render json: @events.limit(params[:limit]).offset(params[:offset]), fan_ticket: true, account_id: params[:account_id], status: :ok
  end

  # GET /fan_tickets/by_event
  swagger_api :by_event do
    summary "Bought tickets by event"
    param :query, :account_id, :integer, :required, "Fan account id"
    param :query, :event_id, :integer, :required, "Event id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def by_event
    render json: {
      event: Event.find(params[:event_id]),
      tickets: FanTicket.joins(:ticket).where(account_id: params[:account_id], tickets: {event_id: params[:event_id]})
    }, fan_ticket: true, account_id: params[:account_id], with_tickets: true, status: :ok
  end

  # GET /fan_tickets/1
  swagger_api :show do
    summary "Fan ticket info"
    param :path, :id, :integer, :required, "FanTicket id"
    param :query, :account_id, :integer, :required, "Fan account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def show
    render json: @fan_ticket, status: :ok
  end

  # POST /fan_tickets
  swagger_api :create do
    summary "Buy ticket"
    param :form, :account_id, :integer, :required, "Fan account id"
    param :form, :ticket_id, :integer, :required, "Ticket id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :forbidden
  end
  def create
    if @ticket.event.is_active?
      @fan_ticket = FanTicket.new(fan_ticket_params)
      @fan_ticket.price = @ticket.price
      @fan_ticket.code = generate_auth_code

      if @fan_ticket.save
        render json: @fan_ticket, status: :created
      else
        render json: @fan_ticket.errors, status: :unprocessable_entity
      end
    else
      render status: :forbidden
    end
  end

   # POST /fan_tickets
  swagger_api :create_many do
    summary "Buy tickets"
    param :form, :account_id, :integer, :required, "Fan account id"
    param :form, :ticket_id, :integer, :required, "Ticket id"
    param :form, :count, :integer, :required, "Count of tickets"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :forbidden
  end
  def create_many
    code = generate_auth_code
    count = params[:count] != nil ? [100, params[:count].to_i].min : 1
    if @ticket.event.is_active?
      cnt = 0
      res = []
      while cnt < count do
        @fan_ticket = FanTicket.new(fan_ticket_params)
        @fan_ticket.price = @ticket.price
        @fan_ticket.code = code

        cnt += 1
        if @fan_ticket.save
          res << @fan_ticket
        else
          render json: @fan_ticket.errors, status: :unprocessable_entity
          res.each do |ticket|
            ticket.destroy
          end
          return
        end
      end
      render json: res
    else
      render status: :forbidden
    end
  end

  # GET /fan_tickets/search
  swagger_api :search do
    summary "Search in account tickets"
    param :query, :account_id, :integer, :required, "Fan account id"
    param_list :query, :time, :string, :required, "Tickets time frame", ['current', 'past']
    param :query, :genres, :string, :optional, "Array of genres"
    param :query, :ticket_types, :string, :optional, "Array of ticket types"
    param :query, :location, :string, :optional, "Location of event"
    param :query, :date_from, :datetime, :optional, "Event date from"
    param :query, :date_to, :datetime, :optional, "Event date to"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :forbidden
  end
  def search
    @events = Event.joins(:tickets => :fan_tickets).where(
      fan_tickets: {account_id: params[:account_id]}
    )

    search_time
    search_genres
    search_types
    search_location
    search_date

    @events = @events.group("events.id")
    render json: @events.limit(params[:limit]).offset(params[:offset]), fan_ticket: true, account_id: params[:account_id], status: :ok
  end

  # DELETE /fan_tickets/1
  swagger_api :destroy do
    summary "Return ticket"
    param :path, :id, :integer, :required, "Ticket id"
    param :form, :account_id, :integer, :required, "Fan account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
  end
  def destroy
    @fan_ticket.destroy
    render status: :ok
  end

  private
    def set_fan_ticket
      @fan_ticket = FanTicket.find(params[:id])
    end

    def set_ticket
      @ticket = Ticket.find(params[:ticket_id])
    end

    def check_ticket
      sold_tickets = FanTicket.where(ticket_id: @ticket.id)

      if sold_tickets and sold_tickets.count >= @ticket.count
        render status: :forbidden
      end
    end

    def generate_auth_code
      return '0000'
    end

    def search_time
      if params[:time] == 'current'
        @events = @events.where(
          "(events.date_from >= :date OR events.date_from IS NULL)", {:date => DateTime.now}
        ).group("events.id")
      else
        @events = @events.where(
          "events.date_from < :date", {:date => DateTime.now}
        ).group("events.id")
      end
    end

    def search_genres
      if params[:genres]
        genres = []
        params[:genres].each do |genre|
          genres.append(EventGenre.genres[genre])
        end
        @events = @events.joins(:genres).where(:event_genres => {genre: genres})
      end
    end

    def search_types
      if params[:ticket_types]
        types = []
        params[:ticket_types].each do |type|
          types.append(TicketsType.names[type])
        end
        @events = @events.joins(:tickets => :tickets_type).where(:tickets_types => {name: types})
      end
    end

    def search_location
      if params[:location]
        @events = @events.near(params[:location])
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

    def fan_ticket_params
      params.permit(:ticket_id, :account_id)
    end

    def authorize_account
      @user = AuthorizeHelper.authorize(request)
      @account = Account.find(params[:account_id])
      render status: :unauthorized if @user == nil or @account.user != @user or @account.account_type != 'fan'
    end
end

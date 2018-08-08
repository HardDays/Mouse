require 'paypal-sdk-rest'
include PayPal::SDK::REST

class FanTicketsController < ApplicationController
  before_action :authorize_account, only: [:create, :create_many, :start_purchase, :destroy]
  before_action :set_ticket, only: [:create, :create_many, :start_purchase]
  before_action :check_ticket, only: [:create, :create_many, :start_purchase]
  before_action :set_fan_ticket, only: [:show, :destroy]
  swagger_controller :fan_ticket, "FanTickets"

  TOKEN_SALT = 'fssdjfi293j29 fsdjd f_ sjfsk jsdf9 sf9j s9'

  # GET /fan_tickets
  swagger_api :index do
    summary "Retrieve list of fan tickets"
    param :query, :account_id, :integer, :required, "Fan account id"
    param_list :query, :time, :string, :optional, "Tickets time frame", ['current', 'past']
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def index
    @events = Event.available.joins(:tickets => :fan_tickets).where(
      fan_tickets: {account_id: params[:account_id]}
    )
    if params[:time]
      filter_by_time
    end
    @events = @events.group("events.id")


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
    }, fan_ticket: true, account_id: params[:account_id], user: @user, with_tickets: true, status: :ok
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

  # POST /fan_tickets/start_purchase
  swagger_api :start_purchase do
    summary "Buy ticket"
    param_list :form, :platform, :string, :required, "Platform", ["yandex", "paypal"]
    param :form, :account_id, :integer, :required, "Fan account id"
    param :form, :ticket_id, :integer, :required, "Ticket id"
    param :form, :count, :integer, :required, "Count of tickets"
    param :form, :redirect_url, :string, :required, "Redirect after success purchase"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :forbidden
  end
  def start_purchase
    if not @ticket.event.status == "active"
      render status: :forbidden and return
    end

    token = Digest::SHA256.hexdigest(@ticket.id.to_s + TOKEN_SALT)
    count = params[:count] != nil ? [100, params[:count].to_i].min : 1

    if params[:platform] == "paypal"
      url = params[:redirect_url] != nil ? params[:redirect_url] : "http://localhost:3000/fan_tickets/finish_paypal"

      @payment = Payment.new({
          intent:  "sale",
          payer:  {
            payment_method:  "paypal" },
          redirect_urls: {
            return_url: params[:redirect_url],
            cancel_url: "http://localhost:3000/"
          },
          transactions:  [{
            item_list: {
              items: [{
                name: "fan_ticket",
                sku: "fan_ticket",
                price: @ticket.price,
                currency: @ticket.currency,
                quantity: count }]},
            amount: {
              total: @ticket.price * count,
              currency: @ticket.currency },
            description: "Buy ticket" }]
      })
        
      if @payment.create
        @transaction = @payment.id
        @url = @payment.links.select{|l| l.rel == 'approval_url'}.first.href
      else
        render json: @payment.error and return
      end   
    else
      rener status: :unprocessable_entity
    end   
    @attempt = PurchaseAttempt.new(account_id: @account.id, 
      status: :pending, 
      purchase_type: :fan_ticket, 
      platform: params[:platform],
      price: @ticket.price,
      transaction_id: @transaction,
      purchase_item_id: @ticket.id,
      count: count,
      token: token)
    @attempt.save
    render json: {transaction_id: @transaction, url: @url}

  end

  # GET /fan_tickets/finish_paypal
  swagger_api :finish_paypal do
    summary "Finish paypal payment, call it after success redirect"
    param :query, :paymentId, :string, :required, "PaymentId"
    response :unauthorized
    response :unprocessable_entity
    response :forbidden
  end
  def finish_paypal
    @attempt = PurchaseAttempt.find_by(
      status: :pending, 
      purchase_type: :fan_ticket, 
      transaction_id: params[:paymentId]
    )
    @payment = Payment.find(params[:paymentId])
    if @payment.execute(payer_id: @payment.payer.payer_info.payer_id)
    else 
      render json: @payment.error and return
    end
    if @attempt
      @ticket = Ticket.find(@attempt.purchase_item_id)

      count = @attempt.count != nil ? @attempt.count : 1

      cnt = 0
      res = []
      while cnt < count do
        @fan_ticket = FanTicket.new(account_id: @attempt.account_id, ticket_id: @ticket.id)
        @fan_ticket.price = @ticket.price
        @fan_ticket.currency = @ticket.currency

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
      @attempt.status = :finished
      @attempt.save
      render json: res
    else
      render json: {PURCHASE_ATTEMPT: :NOT_FOUND}, status: :not_found
    end
  end

  # POST /fan_tickets
  swagger_api :create do
    summary "Buy ticket"
    param :form, :account_id, :integer, :required, "Fan account id"
    param :form, :ticket_id, :integer, :required, "Ticket id"
    param :form, :price, :integer, :required, "Ticket price"
    param_list :form, :currency, :integer, :required, "Preferred currency format", [:RUB, :USD, :EUR]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :forbidden
  end
  def create
    if @ticket.event.status == "active"
      @fan_ticket = FanTicket.new(fan_ticket_params)
      @fan_ticket.code = generate_auth_code

      if @fan_ticket.save
        render json: @fan_ticket, status: :created
      else
        render json: @fan_ticket.errors, status: :unprocessable_entity
      end
    else
      render status: :forbidden and return
    end
  end

   # POST /fan_tickets
  swagger_api :create_many do
    summary "Buy tickets"
    param :form, :account_id, :integer, :required, "Fan account id"
    param :form, :ticket_id, :integer, :required, "Ticket id"
    param :form, :count, :integer, :required, "Count of tickets"
    param :form, :price, :integer, :required, "Ticket price"
    param_list :form, :currency, :integer, :required, "Preferred currency format", [:RUB, :USD, :EUR]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :forbidden
  end
  def create_many
    code = generate_auth_code
    count = params[:count] != nil ? [100, params[:count].to_i].min : 1
    if @ticket.event.status == "active"
      cnt = 0
      res = []
      while cnt < count do
        @fan_ticket = FanTicket.new(fan_ticket_params)
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

    def filter_by_time
      if params[:time] == 'current'
        @events = @events.where(
          "(events.date_to >= :date OR events.date_to IS NULL)", {:date => DateTime.now}
        )
      else
        @events = @events.where(
          "events.date_to < :date", {:date => DateTime.now}
        )
      end
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
      params.permit(:ticket_id, :account_id, :price, :currency)
    end

    def authorize_account
      @account = AuthorizeHelper.auth_and_set_account(request, params[:id])

      if @account == nil or @account.account_type != 'fan'
        render json: {error: "Access forbidden"}, status: :forbidden and return
      end

      @user = @account.user
    end
end

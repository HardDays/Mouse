class TicketsController < ApplicationController
  before_action :auth_creator_and_set_event
  before_action :set_ticket, only: [:show, :update, :destroy]
  before_action :before_change_tickets, only: [:update, :create]

  swagger_controller :tickets, "Tickets"

  # GET events/1/tickets/1
  swagger_api :show do
    summary "Event's ticket"
    param :path, :event_id, :integer, :required, "Event id"
    param :path, :id, :integer, :required, "Ticket id"
    param :query, :account_id, :integer, :required, "Creator id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def show
    render json: @ticket, status: :ok
  end

  # POST events/1/tickets
  swagger_api :create do
    summary "Creates ticket for event"
    param :path, :event_id, :integer, :required, "Event id"
    param :form, :account_id, :integer, :required, "Creator id"
    param :form, :name, :string, :optional, "Ticket name"
    param :form, :description, :string, :optional, "Ticket description"
    param :form, :price, :integer, :required, "Ticket price"
    param :form, :count, :integer, :required, "Ticket count"
    param_list :form, :type, :string, :required, "Ticket type", ["in_person", "vr"]
    param :form, :is_promotional, :boolean, :optional, "Promotional ticket"
    param :form, :promotional_description, :string, :optional, "Promotional ticket description"
    param :form, :promotional_date_from, :datetime, :optional, "Promotional ticket description"
    param :form, :promotional_date_to, :datetime, :optional, "Promotional ticket description"
    param :form, :is_for_personal_use, :boolean, :required, "Ticket for personal use"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :not_found
  end
  def create
    @ticket = Ticket.new(ticket_params)
    set_type

    if @ticket.save
      change_event_tickets

      action = EventUpdate.new(action: :add_ticket, updated_by: @account.id, event_id: @event.id)
      action.save
      
      render json: @ticket, status: :created
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT events/1/tickets/1
  swagger_api :update do
    summary "Update event's ticket"
    param :path, :event_id, :integer, :required, "Event id"
    param :path, :id, :integer, :required, "Ticket id"
    param :form, :account_id, :integer, :required, "Creator id"
    param :form, :name, :string, :optional, "Ticket name"
    param :form, :description, :string, :optional, "Ticket description"
    param :form, :price, :integer, :optional, "Ticket price"
    param :form, :count, :integer, :optional, "Ticket count"
    param_list :form, :type, :string, :optional, "Ticket type", ["in_person", "vr"]
    param :form, :is_promotional, :boolean, :optional, "Promotional ticket"
    param :form, :promotional_description, :string, :optional, "Promotional ticket description"
    param :form, :promotional_date_from, :datetime, :optional, "Promotional ticket description"
    param :form, :promotional_date_to, :datetime, :optional, "Promotional ticket description"
    param :form, :is_for_personal_use, :boolean, :required, "Ticket for personal use"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :unprocessable_entity
    response :not_found
  end
  def update
    if @ticket.update(ticket_params) and allowed?
      set_type
      change_event_tickets

      render json: @ticket, status: :ok
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # DELETE events/1/tickets/1
  swagger_api :destroy do
    summary "Delete event's ticket"
    param :path, :event_id, :integer, :required, "Event id"
    param :path, :id, :integer, :required, "Ticket id"
    param :form, :account_id, :integer, :required, "Creator id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
    response :forbidden
  end
  def destroy
    if @ticket.fan_tickets.empty?
      before_delete_ticket
      @ticket.destroy
      render status: :ok
    else
      render status: :forbidden
    end
  end

  private
    def set_ticket
      @ticket = @event.tickets.find(params[:id])
    end

    def set_type
      if @ticket.tickets_type
        @ticket_type = @ticket.tickets_type
        @ticket_type.update(name: params[:type])
      else
        obj = TicketsType.new(name: params[:type])
        obj.save

        @ticket.tickets_type = obj
      end
    end

    def change_event_tickets
      if params[:type] == "in_person" and @event.has_in_person == false
        @event.has_in_person = true
        @event.save!
      elsif params[:type] == "vr" and @event.has_vr == false
        @event.has_vr = true
        @event.save!
      end
    end

    def before_change_tickets
      tickets_count = @event.tickets.joins(:tickets_type).where(tickets_types: {name: params[:type]}).sum('tickets.count')
      tickets_count += params[:count].to_i

      if params[:type] == 'in_person' and tickets_count > @event.venue.capacity.to_i
        render json: {error: "Tickets limit expired"}, status: :unprocessable_entity and return
      elsif params[:type] == 'vr' and tickets_count > @event.venue.vr_capacity.to_i
        render json: {error: "Tickets limit expired"}, status: :unprocessable_entity and return
      end
    end

    def before_delete_ticket
      ticket_type = @ticket.tickets_type.name
      event_tickets = @event.tickets.joins(
        :tickets_type).where("tickets_types.name = :query", query: TicketsType.names[ticket_type])

      if event_tickets.empty?
        if @ticket.tickets_type.name == "in_person"
          @event.has_in_person = false
          @event.save!
        elsif @ticket.tickets_type.name == "vr"
          @event.has_vr = false
          @event.save!
        end
      end
    end

    def allowed?
      if params[:price]
        bought_tickets = @ticket.fan_tickets.count

        if bought_tickets > 0
          return false
        end
      end

      return true
    end

    def ticket_params
      params.permit(:name, :price, :description, :count, :is_promotional, :promotional_description,
                    :promotional_date_from, :promotional_date_to, :is_for_personal_use, :event_id)
    end

    def authorize_account
      @user = AuthorizeHelper.authorize(request)
      @account = Account.find(params[:account_id])
      render status: :unauthorized if @user == nil or @account.user != @user
    end

    def auth_creator_and_set_event
      authorize_account
      @event = Event.find(params[:event_id])
      @creator = @event.creator
      render status: :unauthorized if @creator != @account or @creator.user != @user
    end
end

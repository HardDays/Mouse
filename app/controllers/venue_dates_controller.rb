class VenueDatesController < ApplicationController
  before_action :set_venue, only: :index
  before_action :authorize_and_set_venue, only: [:create, :destroy, :create_from_array]
  swagger_controller :venue_dates, "Venue dates"

  swagger_api :index do
    summary "Retrieve venue dates"
    param :path, :account_id, :integer, :required, "Venue id"
    param :query, :current_date, :datetime, :optional, "Current date"
    response :not_found
    response :ok
  end

  def index
    if params[:current_date]
      render json: {
        dates: @venue.dates.where(
          date: params[:current_date].to_date.beginning_of_month..params[:current_date].to_date.end_of_month
        ),
        event_dates: @venue.events.where(
          date_from: params[:current_date].to_date.beginning_of_month..params[:current_date].to_date.end_of_month
        ).as_json(only: [:id, :date_from, :date_to])
      }, status: :ok
    else
      render json: {
        dates: @venue.dates,
        event_dates: @venue.events.as_json(only: [:id, :date_from, :date_to])
      }, status: :ok
    end

  end

  swagger_api :create do
    summary "Create venue date"
    param :path, :account_id, :integer, :required, "Venue id"
    param :form, :date, :datetime, :required, "Date"
    param :form, :price_for_daytime, :integer, :optional, "Price for daytime"
    param :form, :price_for_nighttime, :integer, :optional, "Price for nighttime"
    param :form, :is_available, :boolean, :optional, "Is available flag"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :unprocessable_entity
    response :unauthorized
    response :ok
  end

  def create
    date = @venue.dates.find_or_create_by(date: params[:date], venue_id: params[:account_id])

    if date.update(venue_date_update_params(params))
      @venue.dates << date
      @venue.save

      render json: date, status: :ok
    else
      render json: date.errors, status: :unprocessable_entity
    end
  end

  swagger_api :create_from_array do
    summary "Create venue date"
    param :path, :account_id, :integer, :required, "Venue id"
    param :form, :dates, :string, :reqired, "Array of date objects [{'date': '', 'price_for_daytime': '', 'price_for_nighttime': '',
                                                              'is_available': ''}, {...}]"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :unprocessable_entity
    response :unauthorized
    response :ok
  end
  def create_from_array
    params[:dates].each do |date|
      dt = DateTime.parse(date[:date])
      venue_date = VenueDate.find_by('date >= ? and date <= ? and venue_id = ?', dt.beginning_of_day, dt.end_of_day, @venue.id)
      if not venue_date
        venue_date = VenueDate.new(date: date[:date], venue_id: @venue.id)
        if venue_date.save
          @venue.dates << venue_date
          @venue.save
        else
          render json: venue_date.errors, status: :unprocessable_entity and return
        end
      end
      if venue_date.update(venue_date_update_params(date))
      else
        render json: venue_date.errors, status: :unprocessable_entity and return
      end
    end

    render json: @venue.dates, status: :ok
  end

  swagger_api :destroy do
    summary "Destroy venue date"
    param :path, :account_id, :integer, :required, "Venue id"
    param :path, :id, :datetime, :required, "Date"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :unauthorized
    response :ok
  end

  def destroy
    date = @venue.dates.find(params[:id])

    if date
      date.destroy
      render status: :ok
    else
      render status: :not_found
    end
  end

  private
  def set_venue
    account = Account.find_by(id: params[:account_id], account_type: 'venue')
    if account
      @venue = account.venue
    else
      render status: :not_found and return
    end
  end

  def authorize_and_set_venue
    user = AuthorizeHelper.authorize(request)
    account = Account.find(params[:account_id])
    render status: :unauthorized and return if user == nil or account.user != user or account.account_type != 'venue'

    @venue = account.venue
  end

  def venue_date_update_params(params)
    params.permit(:price_for_daytime, :price_for_nighttime, :is_available)
  end
end
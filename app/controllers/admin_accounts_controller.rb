class AdminAccountsController < ApplicationController
  before_action :authorize_admin
  swagger_controller :admin, "AdminPanel"

  # GET /admin/accounts/new
  swagger_api :new_accounts_count do
    summary "Get number of new accounts in the system"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def new_accounts_count
    render json: {
      artist: Account.where(created_at: 1.month.ago..DateTime.now, account_type: 'artist').count,
      fan: Account.where(created_at: 1.month.ago..DateTime.now, account_type: 'fan').count,
      venue: Account.where(created_at: 1.month.ago..DateTime.now, account_type: 'venue').count
    }, status: :ok
  end

  # GET /admin/accounts/new_count
  swagger_api :new_count do
    summary "Get number of new accounts added"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def new_count
    render json: Account.where(status: 'pending').count, status: :ok
  end

  # GET /admin/accounts/user_usage
  swagger_api :user_usage do
    summary "Get users usage of the system"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def user_usage
    render json: {
      likes: Like.count,
      comments: Comment.count,
      clicks: Event.sum(:clicks)
    }, status: :ok
  end

  # GET admin/accounts/requests
  swagger_api :account_requests do
    summary "Get all account requests"
    param :query, :text, :string, :optional, "Search text"
    param_list :query, :account_type, :string, :required, 'Type of accounts', ['all', 'artist', 'fan', 'venue']
    param_list :query, :status, :string, :optional, "Account status", [:pending, :approved, :denied, :active, :inactive]
    param :query, :limit, :integer, :optional, 'Limit'
    param :query, :offset, :integer, :optional, 'Offset'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def account_requests
    accounts = Account.all.order(:created_at => :desc)

    if params[:text]
      accounts = accounts.where("events.name ILIKE :query", query: "%#{params[:text]}%")
    end

    if params[:account_type] != 'all'
      accounts = accounts.where(account_type: params[:account_type])
    end

    if params[:status]
      accounts = accounts.where(status: params[:status])
    end

    render json: accounts.limit(params[:limit]).offset(params[:offset]),
           each_serializer: AdminAccountSerializer,
           status: :ok
  end

  # GET admin/accounts/funding
  swagger_api :funding do
    summary "Get all account requests"
    param :query, :text, :string, :optional, "Search text"
    param_list :query, :account_type, :string, :required, 'Type of accounts', ['all', 'artist', 'fan', 'venue']
    param_list :query, :status, :string, :optional, "Account status", [:pending, :approved, :denied, :active, :inactive]
    param :query, :limit, :integer, :optional, 'Limit'
    param :query, :offset, :integer, :optional, 'Offset'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end
  def funding
    accounts = Account.all.order(:created_at => :desc)

    if params[:text]
      accounts = accounts.where("events.name ILIKE :query", query: "%#{params[:text]}%")
    end

    if params[:account_type] != 'all'
      accounts = accounts.where(account_type: params[:account_type])
    end

    if params[:status]
      accounts = accounts.where(status: params[:status])
    end

    render json: accounts.limit(params[:limit]).offset(params[:offset]),
           each_serializer: AdminAccountBankingSerializer,
           status: :ok
  end

  # GET /admin/accounts/graph
  swagger_api :graph do
    summary "Get accounts info for graph"
    param_list :query, :by, :string, :optional, "Data by", [:day, :week, :month, :year, :all]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def graph
    if params[:by] == 'all'
      dates = Account.pluck("min(created_at), max(created_at)").first
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

    accounts = Account.where(
      created_at: dates_range
    ).order(:account_type, :created_at).to_a.group_by(
      &:account_type
    ).each_with_object({}) {
      |(k, v), h| h[k] = v.group_by{ |e| e.created_at.strftime(GraphHelper.type_str(params[:by])) }
    }.each { |(k, h)|
      h.each { |m, v|
        h[m] = v.count
      }
    }

    render json: {
      axis: axis,
      fan: accounts['fan'],
      artist: accounts['artist'],
      venue: accounts['venue'],
    }, status: :ok
  end

  # GET admin/accounts/<id>
  swagger_api :get_account do
    summary "Retrieve account by id"
    param :path, :id, :integer, :required, "Account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def get_account
    render json: Account.find(params[:id]), extended: true, my: true, status: :ok
  end

  # POST admin/accounts/<id>/approve
  swagger_api :approve do
    summary "Approve account"
    param :path, :id, :integer, :required, "Account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
    response :method_not_allowed
  end
  def approve
    account = Account.find(params[:id])

    if account and ['pending'].include?(account.status)
      account.update(status: 'approved')
      account.update(processed_by: @admin.id)
      render status: :ok
    else
      render status: :method_not_allowed
    end
  end

  # POST admin/accounts/<id>/deny
  swagger_api :deny do
    summary "Deny account"
    param :path, :id, :integer, :required, "Account id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
    response :method_not_allowed
  end
  def deny
    account = Account.find(params[:id])

    if account and ['pending', 'approved'].include?(account.status)
      account.update(status: 'denied')
      account.update(processed_by: @admin.id)
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
    account = Account.find(params[:id])
    account.destroy

    render status: :ok
  end

  private
  def authorize_admin
    user = AuthorizeHelper.authorize(request)
    render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)

    @admin = user.admin
  end
end
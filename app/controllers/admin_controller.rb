class AdminController < ApplicationController

  # TODO: fix it
  before_action :authorize_admin, except: [:make_superuser, :statuses, :get_my]
  before_action :authorize_admin_and_set_user, only: [:get_my]
  swagger_controller :admin, "AdminPanel"

  # POST /admin/make_superuser
  swagger_api :make_superuser do
    summary "Give user a superuser role"
    param :form, :user_id, :integer, :required, "User id"
    param :form, :first_name, :string, :required, "First name"
    param :form, :last_name, :string, :required, "Last name"
    param :form, :user_name, :string, :required, "Mouse username"
  end
  def make_superuser
    user = User.find(params[:user_id])
    user.update(is_superuser: true)

    admin = Admin.new(admin_params)
    admin.user_id = user.id
    if admin.save!
      render json: admin, serializer: AdminSerializer, status: :created
    end
  end

  # GET /admin/<user_id>/my
  swagger_api :get_my do
    summary "Get my admin account"
    param :path, :user_id, :integer, :required, "User id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
    response :not_found
  end
  def get_my
    if @user.admin
      render json: @user.admin, serializer: AdminSerializer, status: :ok
    else
      render status: :not_found
    end
  end

  # POST /admin/create_admin
  swagger_api :create do
    summary "Creates admin credential for login"
    param :form, :image_base64, :string, :optional, "Image base64 string"
    param :form, :first_name, :string, :required, "First name"
    param :form, :last_name, :string, :required, "Last name"
    param :form, :user_name, :string, :required, "Mouse username"
    param :form, :email, :string, :required, "Email"
    param :form, :password, :password, :required, "Your password"
    param :form, :password_confirmation, :password, :required, "Confirm your password"
    param :form, :register_phone, :string, :required, "Phone number"
    param :form, :address, :string, :optional, "Address"
    param :form, :other_address, :string, :optional, "Other address"
    param :form, :city, :string, :optional, "City"
    param :form, :country, :string, :optional, "Country"
    param :form, :state, :string, :optional, "State"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :unauthorized
  end
  def create
    Admin.transaction do
      user = User.new(user_params)
      user.is_admin = true
      user.save!

      @admin = Admin.new(admin_params)
      @admin.user_id = user.id
      if @admin.save!
        set_base64_image
        set_phone_validation

        render json: @admin, serializer: AdminSerializer, status: :created
      end
    end
  end

  # PATCH /admin/create_admin
  swagger_api :update do
    summary "Updates admin credential for login"
    param :path, :id, :integer, :required, "Admin id"
    param :form, :image_base64, :string, :optional, "Image base64 string"
    param :form, :first_name, :string, :optional, "First name"
    param :form, :last_name, :string, :optional, "Last name"
    param :form, :user_name, :string, :optional, "Mouse username"
    param :form, :register_phone, :string, :optional, "Phone number"
    param :form, :address, :string, :optional, "Address"
    param :form, :address_other, :string, :optional, "Other address"
    param :form, :city, :string, :optional, "City"
    param :form, :country, :string, :optional, "Country"
    param :form, :state, :string, :optional, "State"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :unauthorized
  end
  def update
    @admin = Admin.find(params[:id])
    if @admin.update(admin_params)
      set_base64_image
      render json: @admin, serializer: AdminSerializer, status: :ok
    else
      render json: @admin.errors, status: :unprocessable_entity
    end
  end

  # GET /admin/statuses
  swagger_api :statuses do
    summary "Retrieve statuses values"
  end
  def statuses
    render json: StatusHelper.admin_translations, status: :ok
  end


  private
  def authorize_admin
    user = AuthorizeHelper.authorize(request)
    render status: :unauthorized and return if user == nil or (user.is_superuser == false and user.is_admin == false)
  end

  def authorize_admin_and_set_user
    @user = AuthorizeHelper.authorize(request)
    render status: :unauthorized and return if @user == nil or (@user.is_superuser == false and @user.is_admin == false)
  end

  def user_params
    params.permit(:email, :password, :password_confirmation, :register_phone)
  end

  def admin_params
    params.permit(:address, :address_other, :city, :state, :country, :first_name, :last_name, :user_name)
  end

  def set_base64_image
    if params[:image_base64]
      image = Image.new(base64: params[:image_base64])
      image.save
      @admin.image = image
      @admin.save
    end
  end

  def set_phone_validation
    phone_validation = PhoneValidation.new(phone: params[:register_phone], is_validated: true)
    unless phone_validation.save
      render json: phone_validation.errors, status: :unprocessable_entity and return
    end
  end
end

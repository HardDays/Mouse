class UsersController < ApplicationController
  before_action :authorize_me, only: [:update_me, :get_me, :destroy, :set_preferences, :get_preferences]
  swagger_controller :users, "Users"

  # GET /users/me
  swagger_api :get_me do
    summary "Retrives User object of authorized user"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unauthorized
  end

  def get_me
    render json: @user, except: :password
  end

  # POST /users/create
  swagger_api :create do
    summary "Creates user credential for login"
    param :form, :email, :string, :required, "Email"
    param :form, :password, :password, :required, "Your password"
    param :form, :password_confirmation, :password, :optional, "Confirm your password"
    param :form, :register_phone, :string, :optional, "Phone number"
    response :unprocessable_entity
  end

  def create
    if params[:register_phone]
      @phone_validation = PhoneValidation.find_by(phone: params[:register_phone])
      if not @phone_validation or not @phone_validation.is_validated
        render json: {register_phone: [:NOT_VALIDATED]}, status: :unprocessable_entity and return 
      elsif (@phone_validation.updated_at + 10.minutes) < DateTime.now.utc
        render json: {register_phone: [:TIME_EXPIRED]}, status: :unprocessable_entity and return 
      end
      if @phone_validation.is_used
        render json: {register_phone: [:ALREADY_USED]}, status: :unprocessable_entity and return 
      end
    end

    @user = User.new(user_create_params)
    if @user.save
      token = AuthenticateHelper.process_token(request, @user)
      user = @user.as_json
      user[:token] = token.token
      user.delete("password")
      set_base64_image
      if @phone_validation
        @phone_validation.is_used = true
        @phone_validation.save
      end
      render json: user, except: :password, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PUT /users/update/<id>
  def update
    if @user.update(user_update_params)
      render json: @user, except: :password, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PUT /users/update_me
  swagger_api :update_me do
    summary "Update my user info"
    param :form, :email, :string, :optional, "Email"
    param :form, :password, :password, :optional, "Your password"
    param :form, :password_confirmation, :password, :optional, "Confirm your password"
    param :form, :old_password, :password, :optional, "Old password"
    param :form, :register_phone, :string, :optional, "Phone number"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
  end

  def update_me
    if params[:register_phone]
      @phone_validation = PhoneValidation.find_by(phone: params[:register_phone])
      render json: {register_phone: [:NOT_VALIDATED]}, status: :unprocessable_entity and return if not @phone_validation or @phone_validation.is_validated == false
    end

    if @user.update(user_update_params)
      set_base64_image

      render json: @user, except: :password, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH users/1/preferences
  swagger_api :set_preferences do
    summary "Set account preferences"
    param_list :form, :preferred_username, :string, :required, "preferred username language", [:ru, :en]
    param :form, :preferred_date, :string, :required, "Preferred date format"
    param_list :form, :preferred_distance, :integer, :required, "Preferred distance format", [:km, :mi]
    param_list :form, :preferred_currency, :integer, :required, "Preferred currency format", [:RUB, :USD, :EUR]
    param :form, :preferred_time, :string, :required, "Preferred time format"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :unauthorized
  end
  def set_preferences
    if @user.update(user_preferences_params)
      render json: @user, preferences: true, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # GET users/1/preferences
  swagger_api :get_preferences do
    summary "Set account preferences"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :unprocessable_entity
    response :unauthorized
  end
  def get_preferences
    render json: @user, preferences: true, status: :ok
  end

  # DELETE /users
  swagger_api :destroy do
    summary "Delete user"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
  end
  def destroy
    if @user.accounts.count == 0
      if @user.register_phone
        @validation = PhoneValidation.find_by(phone: @user.register_phone)
        if @validation
          @validation.is_used = false
          @validation.save
        end
      end
      @user.destroy
    else
      render status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def find_user
    @to_find = User.find(params[:id])
  end

  def check_access(access)
    return AuthorizeHelper.has_access?(@user, access)
  end

  def authorize
    @user = AuthorizeHelper.authorize(request)
    return @user != nil
  end

  def authorize_me
    render status: :forbidden if not authorize
  end

  def user_create_params
    params.permit(:email, :password, :password_confirmation, :register_phone, :first_name, :last_name, :user_name)
  end

  def user_update_params
    params.permit(:email, :password, :password_confirmation, :old_password,
                  :register_phone, :first_name, :last_name, :user_name)
  end

  def user_preferences_params
    params.permit(:preferred_username,
                  :preferred_date, :preferred_distance, :preferred_currency, :preferred_time)
  end

  def set_base64_image
    if params[:image_base64]
      image = Image.new(base64: params[:image_base64])
      image.save
      @user.image = image
      @user.save
    end
  end
end

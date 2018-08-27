class PhoneValidationsController < ApplicationController
  before_action :set_phone_validation, only: [:show, :update, :destroy]
  swagger_controller :phone, "Phone validation"

  # GET /phone_validations
  def index
    @phone_validations = PhoneValidation.all

    render json: @phone_validations
  end

  # GET /phone_validations/1
  def show
    render json: @phone_validation
  end

  # POST /phone_validations
  swagger_api :create do
    summary "Request code for validation"
    param :form, :phone, :string, :required, "Phone number"
    response :unprocessable_entity
  end
  def create
    phone_validation = PhoneValidation.find_by(phone_validation_params)
    if phone_validation != nil and phone_validation.is_validated == true
      if (phone_validation.updated_at + 10.minutes) > DateTime.now.utc
        render json: {phone: :ALREADY_VALIDATED}, status: :unprocessable_entity and return
      elsif phone_validation.is_used
        render json: {phone: :ALREADY_USED}, status: :unprocessable_entity and return
      else
        phone_validation.destroy
      end
    end

    @phone_validation = PhoneValidation.find_or_create_by(phone_validation_params)
    @phone_validation.code = '0000'
    @phone_validation.is_validated = false
    @phone_validation.is_used = false
    if @phone_validation.save
      render json: @phone_validation, except: :code, status: :created
    else
      render json: @phone_validation.errors, status: :unprocessable_entity
    end
  end

  # POST /phone_validations/resend
  swagger_api :resend do
    summary "Request code for validation"
    param :form, :phone, :string, :required, "Phone number"
    response :unprocessable_entity
  end
  def resend
    @phone_validation = PhoneValidation.find_by(phone: params[:phone])
    if @phone_validation.is_validated
      render status: :unprocessable_entity
    end

    @phone_validation.code = '0000'
    if @phone_validation.save
      render json: @phone_validation, except: :code, status: :created
    else
      render json: @phone_validation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phone_validations/1
  swagger_api :update do
    summary "Send validation code from SMS"
    param :form, :phone, :string, :required, "Phone number"
    param :query, :code, :string, :required, "Code"
    response :unprocessable_entity
  end
  def update
      if params[:code] == @phone_validation.code
          @phone_validation.is_validated = true
          @phone_validation.save
          render json: @phone_validation, except: :code, status: :ok
      else
          render json: {code: [:INVALID]}, status: :unprocessable_entity
      end
  end

  # GET /phone_validations/new_codes
  swagger_api :get_new_codes do
    summary "Retrieve list of phone codes"
  end
  def get_new_codes
    render json: File.read("#{Rails.root}/public/new_phone_codes.json"), status: :ok
  end

  # DELETE /phone_validations/1
  def destroy
    @phone_validation.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phone_validation
      @phone_validation = PhoneValidation.find_by(phone: params[:phone])
      render status: :not_found if not @phone_validation
    end

    # Only allow a trusted parameter "white list" through.
    def phone_validation_params
      params.permit(:phone)
    end
end

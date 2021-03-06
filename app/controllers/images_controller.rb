class ImagesController < ApplicationController
  before_action :authorize_account, only: [:delete_image]
  swagger_controller :images, "Images"

  # GET /images/1
  swagger_api :show do
    summary "Get image object"
    param :path, :id, :integer, :required, "Image id"
    response :not_found
  end
  def show
    @image = Image.find(params[:id])
    render json: @image
  end

  # GET /images/1
  swagger_api :info do
    summary "Get image info object"
    param :path, :id, :integer, :required, "Image id"
    response :not_found
  end
  def info
    @image = Image.where(id: params[:id]).select('id, account_id, created_at, updated_at, event_id, description')
    render json: @image, image_only: true
  end

  swagger_api :full do
    summary "Get full image"
    param :path, :id, :integer, :required, "Image id"
    response :not_found
  end
  def full
    @image = Image.find(params[:id])
    if not @image
      render status: :not_found and return
    end
    send_data Base64.decode64(@image.base64), :type => 'image/png', :disposition => 'inline'
  end

  swagger_api :full_with_size do
    summary "Get full image with size"
    param :path, :id, :integer, :required, "Image id"
    response :not_found
  end
  def full_with_size
    @image = Image.find(params[:id])
    if not @image
      render status: :not_found and return
    end
    blob = Base64.decode64(@image.base64.gsub(/^data:image\/[a-z]+;base64,/, ''))
    image = MiniMagick::Image.read(blob)
    hashed = {
      url: "https://mouse-back.herokuapp.com/images/#{params[:id]}/full",
      width: image.width,
      height: image.height
    }
    render json: hashed
  end
  

  swagger_api :preview do
    summary "Get preview of image object"
    param :path, :id, :integer, :required, "Image id"
    param :query, :width, :integer, :required, "Width to crop"
    param :query, :height, :integer, :required, "Height to crop"
    response :not_found
  end
  def preview
    @resized = ResizedImage.find_by(image_id: params[:id], width: params[:width], height: params[:height])
    if not @resized
      @image = Image.find(params[:id])
      resize
    end
    send_data Base64.decode64(@resized.base64), :type => 'image/png', :disposition => 'inline'
  end

  #DELETE /images/<id>
  swagger_api :delete_image do
    summary "Delete image"
    param :path, :id, :integer, :required, "Image id"
    param :form, :account_id, :integer, :required, "Account/Event owner id"
    param :form, :event_id, :integer, :optional, "Event id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
    response :forbidden
  end
  def delete_image
      @image = Image.find(params[:id])
      if @account.image_id == @image.id
        @account.image = nil
        @image.destroy
        @account.save
        render json: @account, status: :ok and return
      elsif @image.account_id != nil and @image.account.user == @user and @image.account == @account
        @account.image = nil if @account.image == @image
        @image.destroy
        @account.save
        render json: @account, status: :ok and return
      elsif @image.event_id != nil and @image.event.creator.user == @user and @image.event.creator == @account
        _event = @image.event

        _event.image = nil if _event.image == @image
        @image.destroy
        _event.save
        render json: _event, status: :ok and return
      else
        render status: :forbidden
      end
  end

  private
    def authorize_account
      @account = AuthorizeHelper.auth_and_set_account(request, params[:account_id])

      if @account == nil
        render json: {error: "Access forbidden"}, status: :forbidden and return
      end

      @user = @account.user
    end

    def resize
      blob = Base64.decode64(@image.base64.gsub(/^data:image\/[a-z]+;base64,/, ''))

      res_w = params[:width].to_i
      res_h = params[:height].to_i

      image = MiniMagick::Image.read(blob)

      pure = MiniMagick::Tool::Convert.new
      pure << "-"
      pure.resize "#{res_w}x#{res_h}"
      pure << "-"
      res = pure.call(stdin: blob)

      @image.base64 = Base64.encode64(res)

      @resized = ResizedImage.new(base64: @image.base64, width: res_w, height: res_h, image_id: params[:id]) 
      @resized.save
    end

end

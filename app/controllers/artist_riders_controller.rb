class ArtistRidersController < ApplicationController
  swagger_controller :artist_riders, "Artist Riders"

  # GET /artist_riders/1
  swagger_api :show do
    summary "Get full artist riders object"
    param :path, :id, :integer, :required, "Artist rider id"
    response :not_found
  end
  def show
    @rider = ArtistRider.find(params[:id])
    render json: @rider, file_info: true
  end

end

class GenresController < ApplicationController
  swagger_controller :genres, "Genres"

  # GET /genres/all
  swagger_api :all do
    summary "Get genres list"
  end
  def all
    render json: GenresHelper.readable_json, status: :ok
  end

  # GET /genres/artists
  swagger_api :artists do
    summary "Get list of artist by genres"
    param :query, :genres, :string, :optional, "Array of genres ['rap', 'rock', ....]"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
  end
  def artists
    @accounts = Account.where(account_type: :artist)
    search_genre

    render json: @accounts.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  private

  def search_genre
    if params[:genres]
      genres = []
      params[:genres].each do |genre|
        genres.append(ArtistGenre.genres[genre])
      end
      @accounts = @accounts.joins(:artist => :genres).where(:artist_genres => {genre: genres})
    end
  end
end

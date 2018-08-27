class ArtistsController < ApplicationController
    before_action :authorize_user, only: [:create, :get_my_accounts]
    before_action :authorize_account, only: [:update_me, :get_me, :upload_image, :delete_image, :follow, :unfollow]  
    before_action :find_account, only: [:get, :follow, :unfollow, :get_images, :get_followers, :get_followed]  
    before_action :find_image, only: [:delete_image]  
    
    # GET /artists/get/<id>
    def get
        render json: @to_find
    end

    # GET /artists/get_all
    def get_all
        @artists = Artist.all
        render json: @artists.limit(params[:limit]).offset(params[:offset])
    end

    # GET /artists/get_images/<id>
    def get_images
        render json: {
            total_count: @to_find.images.count,
            followers: @to_find.images.limit(params[:limit]).offset(params[:offset]).pluck(:to_id)
        }
    end

    #POST /artists/images
    def upload_image
        image = Image.new(base64: params[:base64])
        image.account = @account
        if image.save
            @account.images << image
            render json: @account, status: :ok
        else
            render json: image.errors, status: :unprocessable_entity
        end
    end

    #DELETE /artists/delete_image/<id>
    def delete_image
        if @image.account == @account
            @account.image = nil if @image == @account.image
            @image.destroy
            @account.save
            render json: @account, status: :ok
        else
            render status: :forbidden
        end
    end

    #POST /artists/upload_image/<id>
    def follow
        follower = Follower.find_by(by_id: @account.id, to_id: @to_find.id)
        if not follower
            follower = Follower.new(by: @account, to: @to_find)  
            if follower.save
                render status: :ok
            else
                render json: follower.errors, status: :unprocessable_entity
            end
        end
    end

    # GET /artists/get_followers/<id>
    def get_followers 
        render json: {
            total_count: @to_find.followers_conn.count,
            followers: @to_find.followers_conn.limit(params[:limit]).offset(params[:offset]).pluck(:by_id)
        }
    end

    # GET /artists/get_followed/<id>
    def get_followed
        render json: {
            total_count: @to_find.followed_conn.count,
            followed: @to_find.followed_conn.limit(params[:limit]).offset(params[:offset]).pluck(:to_id)
        }
    end

    #DELETE /artists/unfollow/<id>
    def unfollow
        follower = Follower.find_by(by_id: @account.id, to_id: @to_find.id)
        if follower 
            follower.destroy
            render status: :ok
        end
    end

    # POST /artists/create
    def create
        @account = Account.new(account_create_params)
        @account.user = @user

        if @account.save
            set_image
            set_artist_params

            @account.save
            #AccessHelper.grant_account_access(@account)
            render json: @account, except: :password, status: :created
        else
            render json: @account.errors, status: :unprocessable_entity
        end
    end

    # PUT /artists/update/<id>
    def update
        set_image
        set_artist_params
        if @account.update(account_update_params)
            render json: @account, except: :password, status: :ok
        else
            render json: @account.errors, status: :unprocessable_entity
        end
    end

    # DELETE /artists/1
    def destroy
      @account.destroy
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def find_account
        @to_find = Account.find(params[:id])
    end

    def authorize_user
        @user = AuthorizeHelper.authorize(request)
        render status: :unauthorized if @user == nil
    end

    def authorize_account
        @user = AuthorizeHelper.authorize(request)
        @account = Account.find(params[:id])
        render status: :unauthorized if @user == nil or @account.user != @user
    end

    def set_image
        if params[:base64]
            #@account.image.delete if @account.image != nil
            image = Image.new(base64: params[:base64])
            image.save
            @account.image = image
            @account.images << image
        end
    end

    def set_artist_params
        if @account.account_type == 'artist'
            if @account.artist
                @artist = @account.artist
                @artist.update(artist_params)

                params.each do |param|
                    if HistoryHelper::ARTIST_FIELDS.include?(param.to_sym)
                        action = HistoryAction.new(action: :update, account_id: @account.id, object_id: @account.id, object_type: :artist, field: param)
                        action.save
                    end
                end
            else
                @artist = Artist.new(artist_params)
                @artist.save
                @account.artist = @artist
            end
            set_artist_genres
        end
    end

    def set_artist_genres
        if params[:genres]
            @artist.genres.clear
            params[:genres].each do |genre|
                obj = ArtistGenre.new(name: genre)
                obj.save
                @artist.genres << obj
            end
        end
    end

    def account_params
        params.permit(:user_name, :phone, :account_type)
    end

    def artist_params
        params.permit(:about)
    end
end

Rails.application.routes.draw do
  resources :questions, only: [:index, :create, :show]
  resources :feedbacks, only: [:index, :create, :show]

  #Auth routes
  post 'auth/login', action: :login, controller: 'authenticate'
  post 'auth/forgot_password', action: :forgot_password, controller: 'authenticate'
  post 'auth/vk', action: :login_vk, controller: 'authenticate'
  post 'auth/google', action: :login_google, controller: 'authenticate'
  post 'auth/twitter', action: :login_twitter, controller: 'authenticate'
  post 'auth/logout', action: :logout, controller: 'authenticate'

  #User routes
  post 'users', action: :create, controller: 'users'
  post 'users/validate_phone', action: :validate_phone, controller: 'users'
  get 'users/me', action: :get_me, controller: 'users'
  patch 'users/me', action: :update_me, controller: 'users'
  patch 'users/:id/email', action: :change_email, controller: 'users'

  #Account routes
  resources :accounts, only: [:create, :update] do
    resources :feed, only: :index
    resources :inbox_messages do
      collection do
        get :my
      end
      member do
        post :change_responce_time
      end
    end
  end
  get 'accounts', action: :get_all, controller: 'accounts'
  get 'accounts/search', action: :search, controller: 'accounts'
  get 'accounts/my', action: :get_my_accounts, controller: 'accounts'
  get 'accounts/:id', action: :get, controller: 'accounts'
  get 'accounts/:id/events', action: :get_events, controller: 'accounts'
  get 'accounts/:id/images', action: :get_images, controller: 'accounts'
  get 'accounts/:id/is_followed', action: :is_followed, controller: 'accounts'
  get 'accounts/:id/followers', action: :get_followers, controller: 'accounts'
  get 'accounts/:id/following', action: :get_followed, controller: 'accounts'
  get 'accounts/:id/updates', action: :get_updates, controller: 'accounts'
  get 'accounts/:id/upcoming_shows', action: :upcoming_shows, controller: 'accounts'
  post 'accounts/follow', action: :follow_multiple, controller: 'accounts'
  post 'accounts/follow', action: :follow_multiple, controller: 'accounts'
  post 'accounts/:id/images', action: :upload_image, controller: 'accounts'
  post 'accounts/:id/follow', action: :follow, controller: 'accounts'
  post 'accounts/:id/verify', action: :verify, controller: 'accounts'
  delete 'accounts/:id/unfollow', action: :unfollow, controller: 'accounts'
  delete 'accounts/:id', action: :delete, controller: 'accounts'
  #delete 'users/delete/:id', action: :delete, controller: 'users'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # images routes
  get 'images/:id', action: :show, controller: 'images'
  get 'images/:id/full', action: :full, controller: 'images'
  get 'images/:id/preview', action: :preview, controller: 'images'
  get 'images/:id/size', action: :full_with_size, controller: 'images'

  delete 'images/:id', action: :delete_image, controller: 'images'

  # artist riders routes
  get 'artist_riders/:id', action: :show, controller: 'artist_riders'

  # phone validations routes
  get 'phone_validations/codes', action: :get_codes, controller: 'phone_validations'
  post 'phone_validations', action: :create, controller: 'phone_validations'
  patch 'phone_validations', action: :update, controller: 'phone_validations'

  # event routes
  get 'events/search', action: :search, controller: 'events'
  get 'events/my', action: :my, controller: 'events'
  resources :events do
    resources :tickets, except: :index
    resources :comments
    resources :likes, only: [:index, :create, :destroy]

    resources :event_venues, path: "venue", only: [:create] do
      member do
        post :send_request
        post :owner_accept
        post :owner_decline
        post :venue_accept
        post :venue_decline
        post :venue_set_active, path: "set_active"
        post :venue_remove_active, path: "remove_active"
      end
    end

    resources :event_artists, path: "artists", only: [:create] do
      member do
        post :send_request
        post :owner_accept
        post :owner_decline
        post :artist_accept
        post :artist_decline
        post :artist_set_active, path: "set_active"
        post :artist_remove_active, path: "remove_active"
      end
    end
  end
  post 'events/:id/activate', action: :set_active, controller: 'events'
  post 'events/:id/like', action: :like, controller: 'events'
  post 'events/:id/unlike', action: :unlike, controller: 'events'
  get 'events/:id/click', action: :click, controller: 'events'
  get 'events/:id/view', action: :view, controller: 'events'
  get 'events/:id/analytics', action: :analytics, controller: 'events'
  get 'events/:id/updates', action: :get_updates, controller: 'events'

  # genre routes
  get 'genres/all', action: :all, controller: 'genres'
  get 'genres/artists', action: :artists, controller: 'genres'

  # feed routes
  get 'feed/action_types', action: :action_types, controller: 'feed'


  # fan tickets routes
  resources :fan_tickets, except: :update do
    collection do
      get :by_event
      get :search
      post :create_many, path: "many"
    end
  end
end

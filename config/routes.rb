Rails.application.routes.draw do
  resources :questions, only: [:index, :create, :show] do
    member do
      post :reply
    end
  end
  resources :feedbacks, only: [:index, :create, :show]

  #Auth routes
  post 'auth/login', action: :login, controller: 'authenticate'
  post 'auth/forgot_password', action: :forgot_password, controller: 'authenticate'
  post 'auth/vk', action: :login_vk, controller: 'authenticate'
  post 'auth/google', action: :login_google, controller: 'authenticate'
  post 'auth/twitter', action: :login_twitter, controller: 'authenticate'
  post 'auth/facebook', action: :login_facebook, controller: 'authenticate'
  post 'auth/logout', action: :logout, controller: 'authenticate'

  #User routes
  post 'users', action: :create, controller: 'users'
  post 'users/validate_phone', action: :validate_phone, controller: 'users'
  get 'users/me', action: :get_me, controller: 'users'
  get 'users/ip_location', action: :get_location, controller: 'users'
  patch 'users/me', action: :update_me, controller: 'users'
  patch 'users/reset_password', action: :reset_password, controller: 'users'
  patch 'users/preferences', action: :set_preferences, controller: 'users'
  get 'users/preferences', action: :get_preferences, controller: 'users'
  patch 'users/:id/email', action: :change_email, controller: 'users'
  delete 'users', action: :destroy, controller: 'users'

  #Account routes
  resources :accounts, only: [:create, :update] do
    resources :feed_items, path: "feed", only: :index do
      resources :feed_comments, path: "comments", only: [:index, :create]
    end
    resources :venue_dates, only: [:index, :create, :destroy] do
      collection do
        post :create_from_array, path: "from_array"
      end
    end
    resources :inbox_messages do
      collection do
        get :my
        get :unread_count
      end
      member do
        post :change_responce_time
        post :read
      end
    end
    resources :artist_videos, only: [:index, :show, :create, :destroy]
    resources :artist_albums, only: [:index, :show, :create, :destroy]
    resources :artist_audios, only: [:index, :show, :create, :destroy]
    resources :venue_videos, only: [:index, :show, :create, :destroy]
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
  post 'accounts/:id/follow_array', action: :follow_multiple, controller: 'accounts'
  post 'accounts/:id/follow', action: :follow, controller: 'accounts'
  post 'accounts/:id/images', action: :upload_image, controller: 'accounts'
  post 'accounts/:id/verify', action: :verify, controller: 'accounts'
  delete 'accounts/:id/unfollow', action: :unfollow, controller: 'accounts'
  delete 'accounts/:id', action: :delete, controller: 'accounts'
  #delete 'users/delete/:id', action: :delete, controller: 'users'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # likes routes
  get 'feed_items/:feed_item_id/likes', action: :index, controller: 'likes'
  post 'feed_items/:feed_item_id/likes', action: :create, controller: 'likes'
  delete 'feed_items/:feed_item_id/likes', action: :destroy, controller: 'likes'

  # images routes
  get 'images/:id', action: :show, controller: 'images'
  get 'images/:id/full', action: :full, controller: 'images'
  get 'images/:id/preview', action: :preview, controller: 'images'
  get 'images/:id/size', action: :full_with_size, controller: 'images'
  get 'images/:id/info', action: :info, controller: 'images'

  delete 'images/:id', action: :delete_image, controller: 'images'

  # artist riders routes
  get 'artist_riders/:id', action: :show, controller: 'artist_riders'

  # phone validations routes
  get 'phone_validations/new_codes', action: :get_new_codes, controller: 'phone_validations'
  post 'phone_validations/resend', action: :resend, controller: 'phone_validations'
  post 'phone_validations', action: :create, controller: 'phone_validations'
  patch 'phone_validations', action: :update, controller: 'phone_validations'

  # event routes
  get 'events/search', action: :search, controller: 'events'
  get 'events/my', action: :my, controller: 'events'
  resources :events do
    resources :tickets, except: :index
    resources :comments, only: [:index, :create]

    resources :event_venues, path: "venue", only: [:create, :destroy] do
      member do
        post :send_request
        post :owner_accept
        post :owner_decline
        post :venue_accept
        post :venue_decline
        post :resend_message
        post :venue_set_active, path: "set_active"
        post :venue_remove_active, path: "remove_active"
      end
    end

    resources :event_artists, path: "artists", only: [:create, :destroy] do
      member do
        post :send_request
        post :owner_accept
        post :owner_decline
        post :artist_accept
        post :artist_decline
        post :resend_message
        post :artist_set_active, path: "set_active"
        post :artist_remove_active, path: "remove_active"
      end
    end
  end
  post '
  /:id/set_date', action: :set_date, controller: 'events'
  post 'events/:id/verify', action: :verify, controller: 'events'
  post 'events/:id/launch', action: :launch, controller: 'events'
  post 'events/:id/deactivate', action: :set_inactive, controller: 'events'
  post 'events/:id/like', action: :like, controller: 'events'
  post 'events/:id/unlike', action: :unlike, controller: 'events'
  get 'events/:id/click', action: :click, controller: 'events'
  get 'events/:id/view', action: :view, controller: 'events'
  get 'events/:id/analytics', action: :analytics, controller: 'events'
  get 'events/:id/updates', action: :get_updates, controller: 'events'
  get 'events/:id/backers', action: :backers, controller: 'events'

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
      get :finish_paypal
      post :start_purchase, path: 'start_purchase'
      post :create_many, path: "many"
    end
  end

  #artist_invites
  post 'artist_invites', action: :create, controller: 'artist_invites'
  
  #venue_invites
  post 'venue_invites', action: :create, controller: 'venue_invites'

  # admin routes
  resources :admin, only: [:index, :create, :update]
  get 'admin/statuses', action: :statuses, controller: 'admin'
  get 'admin/:user_id/my', action: :get_my, controller: 'admin'
  post 'admin/make_superuser', action: :make_superuser, controller: 'admin'

  get 'admin/accounts/new', action: :new_accounts_count, controller: 'admin_accounts'
  get 'admin/accounts/new_count', action: :new_count, controller: 'admin_accounts'
  get 'admin/accounts/requests', action: :account_requests, controller: 'admin_accounts'
  get 'admin/accounts/user_usage', action: :user_usage, controller: 'admin_accounts'
  get 'admin/accounts/funding', action: :funding, controller: 'admin_accounts'
  get 'admin/accounts/graph', action: :graph, controller: 'admin_accounts'
  get 'admin/accounts/:id', action: :get_account, controller: 'admin_accounts'
  post 'admin/accounts/:id/view', action: :view, controller: 'admin_accounts'
  post 'admin/accounts/:id/approve', action: :approve, controller: 'admin_accounts'
  post 'admin/accounts/:id/deny', action: :deny, controller: 'admin_accounts'
  delete 'admin/accounts/:id', action: :destroy, controller: 'admin_accounts'

  get 'admin/events/new_count', action: :new_count, controller: 'admin_events'
  get 'admin/events/new_status', action: :new_status, controller: 'admin_events'
  get 'admin/events/counts', action: :counts, controller: 'admin_events'
  get 'admin/events/requests', action: :event_requests, controller: 'admin_events'
  get 'admin/events/individual', action: :individual, controller: 'admin_events'
  get 'admin/events/graph', action: :graph, controller: 'admin_events'
  get 'admin/events/:id', action: :get_event, controller: 'admin_events'
  post 'admin/events/:id/view', action: :view, controller: 'admin_events'
  post 'admin/events/:id/approve', action: :approve, controller: 'admin_events'
  post 'admin/events/:id/deny', action: :deny, controller: 'admin_events'
  delete 'admin/events/:id', action: :destroy, controller: 'admin_events'

  get 'admin/invites', action: :index, controller: 'admin_invites'
  get 'admin/invites/:id', action: :show, controller: 'admin_invites'
  delete 'admin/invites/:id', action: :destroy, controller: 'admin_invites'


  get 'admin/questions', action: :index, controller: 'admin_questions'
  get 'admin/questions/:id', action: :show, controller: 'admin_questions'
  post 'admin/questions/:id/reply', action: :reply, controller: 'admin_questions'
  post 'admin/questions/:id/close', action: :close, controller: 'admin_questions'
  delete 'admin/questions/:id', action: :destroy, controller: 'admin_questions'

  get 'admin/reply_templates', action: :index, controller: 'admin_reply_templates'
  get 'admin/reply_templates/to_answer', action: :to_answer, controller: 'admin_reply_templates'
  get 'admin/reply_templates/:id', action: :show, controller: 'admin_reply_templates'
  post 'admin/reply_templates', action: :create, controller: 'admin_reply_templates'
  post 'admin/reply_templates/:id/approve', action: :approve, controller: 'admin_reply_templates'
  patch 'admin/reply_templates/:id', action: :update, controller: 'admin_reply_templates'
  delete 'admin/reply_templates/:id', action: :destroy, controller: 'admin_reply_templates'

  get 'admin/feedbacks', action: :index, controller: 'admin_feedback'
  get 'admin/feedbacks/overall', action: :overall, controller: 'admin_feedback'
  get 'admin/feedbacks/counts', action: :counts, controller: 'admin_feedback'
  get 'admin/feedbacks/graph', action: :graph, controller: 'admin_feedback'
  get 'admin/feedbacks/:id', action: :show, controller: 'admin_feedback'
  post 'admin/feedbacks/:id/thank_you', action: :thank_you, controller: 'admin_feedback'
  post 'admin/feedbacks/:id/forward', action: :forward, controller: 'admin_feedback'
  delete 'admin/feedbacks/:id', action: :destroy, controller: 'admin_feedback'

  get 'admin/revenue', action: :index, controller: 'admin_revenue'
  get 'admin/revenue/cities', action: :cities, controller: 'admin_revenue'
  get 'admin/revenue/counts', action: :counts, controller: 'admin_revenue'
  get 'admin/revenue/counts/date', action: :date, controller: 'admin_revenue'
  get 'admin/revenue/counts/artist', action: :artist, controller: 'admin_revenue'
  get 'admin/revenue/counts/venue', action: :venue, controller: 'admin_revenue'
  get 'admin/revenue/counts/vr', action: :vr, controller: 'admin_revenue'
  get 'admin/revenue/counts/tickets', action: :tickets, controller: 'admin_revenue'
  get 'admin/revenue/counts/advertising', action: :advertising, controller: 'admin_revenue'
  get 'admin/revenue/counts/funding', action: :funding, controller: 'admin_revenue'
  get 'admin/revenue/:id', action: :show, controller: 'admin_revenue'

  get 'admin/messages', action: :index, controller: 'admin_messages'
  get 'admin/messages/topics', action: :topics_search, controller: 'admin_messages'
  get 'admin/messages/:id', action: :show, controller: 'admin_messages'
  post 'admin/messages', action: :create, controller: 'admin_messages'
  post 'admin/messages/new', action: :new, controller: 'admin_messages'
  post 'admin/messages/:id/forward', action: :forward, controller: 'admin_messages'
  post 'admin/messages/:id/solve', action: :solve, controller: 'admin_messages'
  post 'admin/messages/:id/read', action: :read, controller: 'admin_messages'
  delete 'admin/messages/:id/delete', action: :delete, controller: 'admin_messages'
  delete 'admin/messages/:id/delete_message', action: :delete_message, controller: 'admin_messages'

  get 'admin/feed', action: :index, controller: 'admin_feed'
end

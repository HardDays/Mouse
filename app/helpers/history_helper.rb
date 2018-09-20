class HistoryHelper 
    EVENT_ACTIONS = [:launch_event, :add_ticket, :add_video, :add_image, :update, :add_artist]
    ACCOUNT_ACTIONS = [:update]

    # Only for check
    EVENT_FIELDS = [:description]
    VENUE_FIELDS = [:address, :phone, :has_vr, :user_name, :display_name]
    ARTIST_FIELDS = [:stage_name, :about, :user_name, :display_name, :phone]

    # Enum in db
    ACCOUNT_FIELDS = [:address, :phone, :has_vr, :about, :user_name, :display_name, :stage_name]
    FIELDS = [:description, :address, :phone, :has_vr, :about, :user_name, :display_name, :stage_name,
              :image, :gallery_image, :video, :audio, :album, :genre]
    ACTIONS = [:launch_event, :add_ticket, :add_video, :add_image, :update, :add_genre, :add_artist]
end

class HistoryHelper 
    EVENT_ACTIONS = [:launch_event, :add_ticket, :add_video, :add_image, :update]
    ACCOUNT_ACTIONS = [:update]

    # Only for check
    EVENT_FIELDS = [:description]
    VENUE_FIELDS = [:address, :phone, :has_vr, :user_name, :display_name]
    ARTIST_FIELDS = [:stage_name, :about, :user_name, :display_name, :phone]
    ACCOUNT_FIELDS = [:address, :phone, :has_vr, :about, :user_name, :display_name, :image, :gallery_image, :stage_name]

    # Enum to write in db
    FIELDS = [:description, :address, :phone, :has_vr, :about, :user_name, :display_name, :image, :gallery_image, :stage_name]
    ACTIONS = [:launch_event, :add_ticket, :add_video, :add_image, :update]
end

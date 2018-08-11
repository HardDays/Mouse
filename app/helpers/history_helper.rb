class HistoryHelper 
    EVENT_ACTIONS = [:add_event, :add_ticket, :add_video, :add_image, :update]
    ACCOUNT_ACTIONS = [:update]

    # Only for check
    EVENT_FIELDS = [:name, :tagline, :description, :date_from, :date_to, :funding_goal,
                    :event_season, :event_year, :event_length, :event_time, :address, :genres,
                    :collaborators, :updates_available, :comments_available, :user_name, :display_name, :phone]
    VENUE_FIELDS = [:name, :address, :phone, :has_vr, :user_name, :display_name, :phone]
    ARTIST_FIELDS = [:name, :about, :user_name, :display_name, :phone, :first_name, :last_name, :stage_name]
    # Enum to write in db
    ACCOUNT_FIELDS = [:name, :address, :phone, :has_vr, :about, :user_name, :display_name, :phone]

end

class HistoryHelper 
    EVENT_ACTIONS = [:add_ticket, :add_video, :add_image, :update]
    ACCOUNT_ACTIONS = [:update]

    # Only for check
    EVENT_FIELDS = [:name, :tagline, :description, :date_from, :date_to, :funding_goal,
                    :event_season, :event_year, :event_length, :event_time, :address, :genres,
                    :collaborators, :updates_available, :comments_available]
    VENUE_FIELDS = [:name, :address, :phone, :has_vr]
    ARTIST_FIELDS = [:name, :about]
    # Enum to write in db
    ACCOUNT_FIELDS = [:name, :address, :phone, :has_vr, :about]

end

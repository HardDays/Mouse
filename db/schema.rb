# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180729122219) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accept_messages", force: :cascade do |t|
    t.datetime "preferred_date_from"
    t.datetime "preferred_date_to"
    t.integer "price"
    t.integer "travel_price"
    t.integer "hotel_price"
    t.integer "transportation_price"
    t.integer "band_price"
    t.integer "other_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inbox_message_id"
    t.integer "event_id"
  end

  create_table "account_updates", force: :cascade do |t|
    t.integer "account_id"
    t.integer "updated_by"
    t.integer "action"
    t.integer "field"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "image_id"
    t.string "phone"
    t.integer "fan_id"
    t.integer "artist_id"
    t.integer "venue_id"
    t.integer "account_type"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_name"
    t.string "display_name"
    t.boolean "is_verified", default: false
    t.integer "status", default: 0
    t.integer "processed_by"
    t.string "preferred_username"
    t.string "preferred_date"
    t.integer "preferred_distance", default: 1
    t.integer "preferred_currency", default: 1
    t.string "preferred_time"
  end

  create_table "admins", force: :cascade do |t|
    t.string "address"
    t.string "address_other"
    t.integer "user_id"
    t.string "country"
    t.string "city"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "user_name"
    t.integer "image_id"
  end

  create_table "agreed_date_time_and_prices", force: :cascade do |t|
    t.datetime "datetime_from"
    t.datetime "datetime_to"
    t.integer "price"
    t.integer "venue_event_id"
    t.integer "artist_event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artist_albums", force: :cascade do |t|
    t.integer "artist_id"
    t.string "album_name"
    t.string "album_artwork"
    t.string "album_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artist_dates", force: :cascade do |t|
    t.integer "artist_id"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artist_events", force: :cascade do |t|
    t.integer "event_id"
    t.integer "artist_id"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: false
  end

  create_table "artist_genres", force: :cascade do |t|
    t.integer "artist_id"
    t.integer "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artist_preferred_venues", force: :cascade do |t|
    t.integer "type_of_venue"
    t.integer "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artist_riders", force: :cascade do |t|
    t.integer "artist_id"
    t.integer "rider_type"
    t.string "uploaded_file"
    t.string "description"
    t.boolean "is_flexible", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uploaded_file_base64"
  end

  create_table "artist_videos", force: :cascade do |t|
    t.integer "artist_id"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "album_name"
  end

  create_table "artists", force: :cascade do |t|
    t.string "about"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "lat"
    t.float "lng"
    t.string "preferred_address"
    t.string "first_name"
    t.string "last_name"
    t.string "facebook"
    t.string "twitter"
    t.string "instagram"
    t.string "snapchat"
    t.string "spotify"
    t.string "soundcloud"
    t.string "youtube"
    t.string "stage_name"
    t.string "manager_name"
    t.integer "performance_min_time"
    t.integer "performance_max_time"
    t.integer "price_from"
    t.integer "price_to"
    t.integer "additional_hours_price"
    t.boolean "is_hide_pricing_from_profile", default: false
    t.boolean "is_hide_pricing_from_search", default: false
    t.integer "days_to_travel"
    t.boolean "is_perform_with_band", default: false
    t.boolean "can_perform_without_band", default: false
    t.boolean "is_perform_with_backing_vocals", default: false
    t.boolean "can_perform_without_backing_vocals", default: false
    t.boolean "is_permitted_to_stream", default: false
    t.boolean "is_permitted_to_advertisement", default: false
    t.boolean "has_conflict_contracts", default: false
    t.string "conflict_companies_names"
    t.string "preferred_venue_text"
    t.integer "min_time_to_book"
    t.integer "min_time_to_free_cancel"
    t.integer "late_cancellation_fee"
    t.string "refund_policy"
    t.string "artist_email"
  end

  create_table "audio_links", force: :cascade do |t|
    t.integer "artist_id"
    t.string "audio_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "song_name"
    t.string "album_name"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "event_id"
    t.integer "account_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "decline_messages", force: :cascade do |t|
    t.integer "reason"
    t.string "additional_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inbox_message_id"
    t.integer "event_id"
  end

  create_table "event_collaborators", force: :cascade do |t|
    t.integer "event_id"
    t.integer "collaborator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_genres", force: :cascade do |t|
    t.integer "event_id"
    t.integer "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_updates", force: :cascade do |t|
    t.integer "event_id"
    t.integer "updated_by"
    t.integer "action"
    t.integer "field"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "tagline"
    t.string "description", limit: 500
    t.datetime "funding_from"
    t.datetime "funding_to"
    t.integer "funding_goal", default: 0
    t.integer "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: false
    t.integer "views", default: 0
    t.integer "clicks", default: 0
    t.boolean "has_vr", default: false
    t.boolean "has_in_person", default: false
    t.boolean "updates_available", default: false
    t.boolean "comments_available", default: false
    t.datetime "date_from"
    t.datetime "date_to"
    t.integer "event_season"
    t.integer "event_year"
    t.integer "event_length"
    t.integer "event_time"
    t.boolean "is_crowdfunding_event", default: true
    t.float "city_lat"
    t.float "city_lng"
    t.integer "artists_number", default: 6
    t.integer "venue_id"
    t.string "address"
    t.string "old_address"
    t.float "old_city_lat"
    t.float "old_city_lng"
    t.integer "image_id"
    t.string "video_link"
    t.datetime "old_date_from"
    t.datetime "old_date_to"
    t.string "hashtag"
    t.integer "additional_cost"
    t.integer "family_and_friends_amount"
    t.integer "status", default: 0
    t.boolean "has_private_venue"
    t.integer "processed_by"
  end

  create_table "fan_genres", force: :cascade do |t|
    t.integer "fan_id"
    t.integer "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fan_tickets", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "account_id"
    t.string "code"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fans", force: :cascade do |t|
    t.string "bio"
    t.string "address"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer "feedback_type"
    t.string "detail", default: ""
    t.integer "rate_score"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "message_id"
  end

  create_table "followers", force: :cascade do |t|
    t.integer "by_id"
    t.integer "to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forgot_pass_attempts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "attempt_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "history_actions", force: :cascade do |t|
    t.integer "action"
    t.integer "object_type"
    t.integer "field"
    t.integer "object_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
  end

  create_table "image_types", force: :cascade do |t|
    t.integer "image_id"
    t.integer "image_type"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "images", force: :cascade do |t|
    t.string "base64"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_id"
    t.string "description"
  end

  create_table "inbox_messages", force: :cascade do |t|
    t.integer "receiver_id"
    t.integer "message_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "sender_id"
    t.boolean "is_read", default: false
    t.string "simple_message"
    t.integer "admin_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
  end

  create_table "phone_validations", force: :cascade do |t|
    t.string "phone"
    t.boolean "is_validated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.boolean "is_used"
  end

  create_table "public_venues", force: :cascade do |t|
    t.string "fax"
    t.string "bank_name"
    t.string "account_bank_number"
    t.string "account_bank_routing_number"
    t.integer "num_of_bathrooms"
    t.integer "min_age"
    t.boolean "has_bar"
    t.integer "located"
    t.string "dress_code"
    t.string "audio_description"
    t.string "lighting_description"
    t.string "stage_description"
    t.integer "venue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "type_of_space"
    t.integer "price"
    t.string "country"
    t.string "city"
    t.string "state"
    t.integer "zipcode"
    t.integer "minimum_notice"
    t.boolean "is_flexible"
    t.integer "price_for_daytime"
    t.integer "price_for_nighttime"
    t.time "performance_time_from"
    t.time "performance_time_to"
    t.string "other_genre_description"
    t.string "other_address", default: ""
    t.string "street"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "account_id"
    t.string "subject"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "message_id"
  end

  create_table "reply_templates", force: :cascade do |t|
    t.string "subject"
    t.string "message"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "request_messages", force: :cascade do |t|
    t.integer "time_frame"
    t.boolean "is_personal", default: false
    t.integer "estimated_price"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inbox_message_id"
    t.integer "event_id"
    t.datetime "expiration_date"
    t.integer "remain_time"
    t.integer "time_frame_range", default: 0
    t.integer "time_frame_number", default: 0
  end

  create_table "resized_images", force: :cascade do |t|
    t.string "base64"
    t.integer "image_id"
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "price"
    t.integer "count"
    t.boolean "is_for_personal_use"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "video"
    t.boolean "is_promotional", default: false
    t.string "promotional_description"
    t.datetime "promotional_date_from"
    t.datetime "promotional_date_to"
  end

  create_table "tickets_types", force: :cascade do |t|
    t.integer "name"
    t.integer "ticket_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.string "token"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "info"
  end

  create_table "user_genres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "name"
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_id"
    t.string "twitter_id"
    t.string "register_phone"
    t.string "vk_id"
    t.string "first_name"
    t.string "last_name"
    t.string "user_name"
    t.integer "image_id"
    t.boolean "is_superuser", default: false
    t.boolean "is_admin", default: false
  end

  create_table "venue_dates", force: :cascade do |t|
    t.integer "venue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date"
    t.integer "price_for_daytime"
    t.integer "price_for_nighttime"
    t.boolean "is_available", default: true
  end

  create_table "venue_emails", force: :cascade do |t|
    t.integer "venue_id"
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "venue_events", force: :cascade do |t|
    t.integer "venue_id"
    t.integer "event_id"
    t.integer "status"
    t.datetime "rental_from"
    t.datetime "rental_to"
    t.string "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_active", default: false
  end

  create_table "venue_genres", force: :cascade do |t|
    t.integer "venue_id"
    t.integer "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "venue_office_hours", force: :cascade do |t|
    t.integer "venue_id"
    t.integer "day"
    t.time "begin_time"
    t.time "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "venue_operating_hours", force: :cascade do |t|
    t.integer "venue_id"
    t.integer "day"
    t.time "begin_time"
    t.time "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "venue_video_links", force: :cascade do |t|
    t.integer "venue_id"
    t.string "video_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "venues", force: :cascade do |t|
    t.string "address"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.integer "capacity"
    t.integer "venue_type"
    t.boolean "has_vr"
    t.integer "vr_capacity", default: 200
  end

end

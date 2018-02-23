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

ActiveRecord::Schema.define(version: 20180222215120) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_updates", force: :cascade do |t|
    t.integer "account_id"
    t.integer "updated_by"
    t.integer "action"
    t.integer "field"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "account_video_links", force: :cascade do |t|
    t.integer "account_id"
    t.string "link"
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
  end

  create_table "artist_events", force: :cascade do |t|
    t.integer "event_id"
    t.integer "artist_id"
    t.integer "status"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artist_genres", force: :cascade do |t|
    t.integer "artist_id"
    t.integer "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists", force: :cascade do |t|
    t.string "about"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price"
    t.float "lng"
    t.float "lat"
    t.string "address"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "event_id"
    t.integer "account_id"
    t.string "text"
    t.datetime "created_at", default: "2018-02-09 20:31:48", null: false
    t.datetime "updated_at", default: "2018-02-09 20:31:48", null: false
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
    t.integer "funding_goal"
    t.integer "creator_id"
    t.integer "artist_id"
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
    t.integer "event_month"
    t.integer "event_year"
    t.integer "event_length"
    t.integer "event_time"
    t.boolean "is_crowdfunding_event"
    t.float "city_lat"
    t.float "city_lng"
    t.integer "artists_number"
    t.integer "venue_id"
    t.string "address"
    t.string "old_address"
    t.float "old_city_lat"
    t.float "old_city_lng"
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

  create_table "images", force: :cascade do |t|
    t.string "base64"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "likes", force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phone_validations", force: :cascade do |t|
    t.string "phone"
    t.boolean "is_validated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
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
    t.string "lightning_description"
    t.string "stage_description"
    t.integer "venue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "is_special"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "video"
  end

  create_table "tickets_categories", force: :cascade do |t|
    t.integer "name"
    t.integer "ticket_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "venue_dates", force: :cascade do |t|
    t.integer "venue_id"
    t.date "begin_date"
    t.date "end_date"
    t.integer "is_available"
    t.integer "price"
    t.integer "booking_notice"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "venues", force: :cascade do |t|
    t.string "address"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "phone"
    t.integer "capacity"
    t.integer "venue_type"
    t.boolean "has_vr"
  end

end

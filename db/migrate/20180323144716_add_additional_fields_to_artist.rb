class AddAdditionalFieldsToArtist < ActiveRecord::Migration[5.1]
  def change
    add_column :artists, :stage_name, :string
    add_column :artists, :manager_name, :string
    add_column :artists, :performance_min_time, :integer
    add_column :artists, :performance_max_time, :integer
    remove_column :artists, :price, :integer
    add_column :artists, :price_from, :integer
    add_column :artists, :price_to, :integer
    add_column :artists, :additional_hours_price, :integer
    add_column :artists, :is_hide_pricing_from_profile, :boolean, default: false
    add_column :artists, :is_hide_pricing_from_search, :boolean, default: false
    rename_column :artists, :address, :preferred_address
    add_column :artists, :days_to_travel, :integer
    add_column :artists, :is_perform_with_band, :boolean, default: false
    add_column :artists, :can_perform_without_band, :boolean, default: false
    add_column :artists, :is_perform_with_backing_vocals, :boolean, default: false
    add_column :artists, :can_perform_without_backing_vocals, :boolean, default: false
    add_column :artists, :is_permitted_to_stream, :boolean, default: false
    add_column :artists, :is_permitted_to_advertisement, :boolean, default: false
    add_column :artists, :has_conflict_contracts, :boolean, default: false
    add_column :artists, :conflict_companies_names, :string
    add_column :artists, :preferred_venue_text, :string
    add_column :artists, :min_time_to_book, :integer
    add_column :artists, :min_time_to_free_cancel, :integer
    add_column :artists, :late_cancellation_fee, :integer
    add_column :artists, :refund_policy, :string
    remove_column :artists, :is_price_private, :boolean
    remove_column :artists, :technical_rider, :string
    remove_column :artists, :stage_rider, :string
    remove_column :artists, :backstage_rider, :string
    remove_column :artists, :hospitality, :string

    add_column :audio_links, :song_name, :string
    add_column :audio_links, :album_name, :string

    add_column :account_video_links, :name, :string
    add_column :account_video_links, :album_name, :string

    remove_column :artist_events, :reason, :string
  end
end

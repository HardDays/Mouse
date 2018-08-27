class Account < ApplicationRecord
	 
	validates :account_type, presence: true

	enum account_type: [:venue, :artist, :fan]
	enum status: StatusHelper.accounts
	enum preferred_distance: [:km, :mile]
	enum preferred_currency: [:RUB, :USD, :EUR]

	validates :user_name, presence: true, uniqueness: true, length: {:within => 3..30}

	has_many :images, dependent: :destroy

	has_many :followers_conn, foreign_key: 'to_id', class_name: 'Follower', dependent: :destroy
	has_many :followers, through: :followers_conn, source: 'by'

	has_many :followings_conn, foreign_key: 'by_id', class_name: 'Follower', dependent: :destroy
	has_many :following, through: :followings_conn, source: 'to'

	has_many :venue_events, foreign_key: 'venue_id'
	has_many :artist_events, foreign_key: 'artist_id'

	has_many :sent_messages, foreign_key: 'sender_id', class_name: 'InboxMessage'
	has_many :inbox_messages, foreign_key: 'receiver_id', class_name: 'InboxMessage'

	belongs_to :user
	belongs_to :fan, optional: true
	belongs_to :artist, optional: true
	belongs_to :venue, optional: true
	belongs_to :admin, foreign_key: 'processed_by', class_name: 'Admin', optional: true

	belongs_to :image, optional: true

	has_many :event_collaborators, foreign_key: :collaborator_id
	has_many :collaborated, through: :event_collaborators, source: :event, class_name: 'Event', dependent: :destroy
	has_many :events, foreign_key: 'creator_id'
	has_many :likes
	has_many :account_updates


	def get_attrs
		attrs = {}
		attrs[:id] = id
		attrs[:user_name] = user_name
		attrs[:display_name] = display_name
		attrs[:phone] = phone
		attrs[:created_at] = created_at
		attrs[:updated_at] = updated_at
		attrs[:image_id] = image_id
		attrs[:is_verified] = is_verified
		attrs[:account_type] = account_type

		attrs[:preferred_username] = preferred_username
		attrs[:preferred_date] = preferred_date
		attrs[:preferred_distance] = preferred_distance
		attrs[:preferred_currency] = preferred_currency
		attrs[:preferred_time] = preferred_time

		attrs[:status] = status
		attrs[:followers_count] = followers.count
		attrs[:following_count] = following.count
		return attrs
	end

    def as_json(options={})
			if options[:for_message]
				attrs = {}
				attrs[:image_id] = image_id
				attrs[:user_name] = user_name
				attrs[:account_type] = account_type

				if fan
					attrs[:full_name] = "#{fan.first_name} #{fan.last_name}"
				elsif artist
					attrs[:full_name] = "#{artist.first_name} #{artist.last_name}"
				elsif venue
					attrs[:full_name] = display_name
				end

				return attrs
			end

			if not options[:only]
				if fan
					return fan.as_json(options)
				end

				if venue
					return venue.as_json(options)
			#   venue_attrs = venue.as_json
			#   venue_attrs.each do |att|
			# 	  attrs[att[0]] = att[1] if not attrs.key?(att[0])
			#   end
				end

				if artist
						return artist.as_json(options)
				end

				#attrs[:genres] = user_genres.pluck(:name)
				#attrs[:images] = images.pluck(:id)
				#attrs[:followed] = followed_conn.pluck(:to_id)
				#attrs[:followers] = followers_conn.pluck(:by_id)
				return get_attrs
			else
				return super(options)
			end
	end

	def self.search(text)
		return self.where(
			"accounts.user_name ILIKE :query", query: "%#{sanitize_sql_like(text)}%"
		).or(
			Account.where("accounts.display_name ILIKE :query", query: "%#{sanitize_sql_like(text)}%")
		)
	end
end

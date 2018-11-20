class Account < ApplicationRecord
	scope :available, -> {where(is_deleted: false)}
	scope :approved, -> {where(status: 'approved')}

	validates :account_type, presence: true
	validates :user_name, presence: true, uniqueness: true, length: {:within => 3..30}

	enum account_type: [:venue, :artist, :fan]
	enum status: StatusHelper.accounts

	has_many :images, dependent: :destroy

	has_many :followers_conn, foreign_key: 'to_id', class_name: 'Follower', dependent: :destroy
	has_many :followers, through: :followers_conn, source: 'by'

	has_many :followings_conn, foreign_key: 'by_id', class_name: 'Follower', dependent: :destroy
	has_many :following, through: :followings_conn, source: 'to'

	has_many :venue_events, foreign_key: 'venue_id', dependent: :nullify
	has_many :artist_events, foreign_key: 'artist_id', dependent: :nullify

	has_many :sent_messages, foreign_key: 'sender_id', class_name: 'InboxMessage', dependent: :nullify
	has_many :inbox_messages, foreign_key: 'receiver_id', class_name: 'InboxMessage', dependent: :nullify

	belongs_to :user
	belongs_to :fan, optional: true, dependent: :destroy
	belongs_to :artist, optional: true, dependent: :destroy
	belongs_to :venue, optional: true, dependent: :destroy
	belongs_to :admin, foreign_key: 'processed_by', class_name: 'Admin', optional: true, dependent: :destroy

	belongs_to :image, optional: true

	has_many :event_collaborators, foreign_key: :collaborator_id, dependent: :nullify
	has_many :collaborated, through: :event_collaborators, source: :event, class_name: 'Event'
	has_many :events, foreign_key: 'creator_id', dependent: :nullify
	has_many :likes, dependent: :nullify
	has_many :feed_items, dependent: :nullify
	has_many :fan_tickets, dependent: :nullify
	#has_many :comments, dependent: :nullify


	def get_attrs(options={})
		attrs = {}
		attrs[:id] = id
		attrs[:user_name] = user_name
		attrs[:display_name] = display_name
		if fan
			attrs[:phone] = user.register_phone
		else
			attrs[:phone] = phone
		end
		attrs[:created_at] = created_at
		attrs[:updated_at] = updated_at
		attrs[:image_id] = image_id
		attrs[:account_type] = account_type

		attrs[:status] = status
		attrs[:followers_count] = followers.count
		attrs[:following_count] = following.count

		if options[:account]
			follower = Follower.find_by(by_id: options[:account].id, to_id: id)
			attrs[:is_followed] = follower != nil
		end

		return attrs
	end

	def as_json(options={})
		if options[:for_message]
			attrs = {}
			attrs[:image_id] = image_id
			attrs[:user_name] = user_name
			attrs[:account_type] = account_type
			attrs[:display_name] = display_name

			if fan
				attrs[:full_name] = "#{fan.first_name} #{fan.last_name}"
				attrs[:address] = fan.address
			elsif artist
				attrs[:full_name] = "#{artist.first_name} #{artist.last_name}"
				attrs[:address] = artist.preferred_address
			elsif venue
				attrs[:full_name] = display_name
				attrs[:address] = venue.address
			end

			return attrs
		end

		if options[:backers]
			attrs = {}
			attrs[:id] = id
			attrs[:image_id] = image_id
			attrs[:user_name] = user_name

			if fan
				attrs[:first_name] = fan.first_name
				attrs[:last_name] = fan.last_name
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
			return get_attrs(options)
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

	def self.search_fan_fullname(text)
		return self.joins(:fan).where(
			"(fans.first_name ILIKE :query OR fans.last_name ILIKE :query)", query: "%#{sanitize_sql_like(text)}%"
		).or(
			Account.joins(:fan).where("accounts.display_name ILIKE :query", query: "%#{sanitize_sql_like(text)}%")
		)
	end
end

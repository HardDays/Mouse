class Event < ApplicationRecord
  belongs_to :creator, class_name: 'Account'

  has_many :event_collaborators, foreign_key: 'event_id'
  has_many :collaborators, through: :event_collaborators, class_name: 'Account'

  has_many :tickets, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, foreign_key: 'event_id', dependent: :destroy
  has_many :event_updates

  has_many :venue_events, foreign_key: 'event_id'
  has_many :venues, through: :venue_events, source: :account, class_name: 'Account'

  has_many :genres, foreign_key: 'event_id', class_name: 'EventGenre', dependent: :destroy
  belongs_to :artist, optional: true

  def as_json(options={})
    res = super
    res.delete('artist_id')
    res.delete('venue_id')
    res[:backers] = tickets.joins(:fan_tickets).pluck(:account_id).uniq.count
    res[:founded] = tickets.joins(:fan_tickets).sum("fan_tickets.price")

    if options[:extended]
      res[:collaborators] = collaborators
      res[:genres] = genres.pluck(:genre)
      res[:artist] = artist
      res[:venue] = venues
      res[:tickets] = tickets.as_json(only: [:id, :name, :type])
    elsif options[:analytics]
      # res[:location] = venue.address if venue
      res[:comments] = comments.count
      res[:likes] = likes.count
    else
      # res[:location] = venue.address if venue
    end
    return res
  end

  def self.simple_search(text)
    @events = Event.all
    if text
      @events = @events.where(
        "events.name ILIKE :query", query: "%#{sanitize_sql_like(text)}%"
      )
    end

    return @events
  end

  def self.search(text="")
    @events = Event.all

    if text
      @events = @events.joins(:artist => :account, :venue => :account).where(
        "events.name ILIKE :query", query: "%#{sanitize_sql_like(text)}%"
      ).or(
        Event.joins(:artist => :account, :venue => :account).where("events.tagline ILIKE :query", query: "%#{sanitize_sql_like(text)}%")
      ).or(
        Event.joins(:artist => :account, :venue => :account).where("events.description ILIKE :query", query: "%#{sanitize_sql_like(text)}%")
      ).or(
        Event.joins(:artist => :account, :venue => :account).where("accounts.display_name ILIKE :query", query: "%#{sanitize_sql_like(text)}%")
      ).or(
        Event.joins(:artist => :account, :venue => :account).where("accounts_venues.display_name ILIKE :query", query: "%#{sanitize_sql_like(text)}%")
      )
    end

    return @events
  end
end

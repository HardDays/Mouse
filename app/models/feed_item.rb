class FeedItem < ApplicationRecord
  enum action: HistoryHelper::ACTIONS, _suffix: true
  enum field: HistoryHelper::FIELDS, _suffix: true

  belongs_to :account, optional: true
  belongs_to :event, optional: true

  has_many :feed_comments
  has_many :likes

  def as_json(options={})
    res = super

    if options[:only]
      return super(options)
    end

    res[:deleted] = false
    res[:comments] = feed_comments.count
    res[:likes] = likes.count
    if options[:user]
      res[:is_liked] = likes.where(user_id: options[:user].id).exists?
    end

    if event
      res[:type] = "event_update"
      res[:action] = [action, field].compact.join("_")
      res[:event] = event.as_json(only: [:id, :name, :comments_available, :display_name])
      res[:account] = event.creator.as_json(:only => [:id, :user_name, :image_id, :display_name])

      if action == 'add_ticket'
        ticket = event.tickets.where(id: value.to_i).first
        if ticket
          res[:ticket] = ticket
        else
          res[:deleted] = true
        end
      elsif action == 'add_artist'
        artist = Account.where(id: value.to_i).first
        if artist
          res[:artist] = artist
        else
          res[:deleted] = true
        end
      elsif action == 'update' and field == 'image'
        image = Image.where(id: value.to_i).first
        if image
          res[:value] = value
        else
          res[:deleted] = true
        end
      else
        res[:value] = value
      end
    elsif account
      res[:type] = "account_update"
      res[:action] = [action, field].compact.join("_")
      res[:account] = account

      if action == "update"
        if field == 'gallery_image' or field == 'image'
          image = Image.where(id: value.to_i).first
          if image
            res[:value] = value
          else
            res[:deleted] = true
          end
        elsif field == "video"
          artist_video = ArtistVideo.where(id: value.to_i).first
          venue_video = VenueVideoLink.where(id: value.to_i).first

          if artist_video or venue_video
            res[:value] = value
          else
            res[:deleted] = true
          end
        elsif field == "audio"
          audio = AudioLink.where(id: value.to_i).first

          if audio
            res[:value] = value
          else
            res[:deleted] = true
          end
        elsif field == "album"
          album = ArtistAlbum.where(id: value.to_i).first

          if album
            res[:value] = value
          else
            res[:deleted] = true
          end
        end
      else
        res[:value] = value
      end
    end

    return res
  end
end

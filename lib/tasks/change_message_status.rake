desc "This task is called by the Heroku scheduler add-on"
namespace :messages do
  desc "Change status of message if expired"
  task change_message_status: :environment do
    event_artists = ArtistEvent.where(status: "request_send")
    puts "artists"

    ActiveRecord::Base.transaction do
      event_artists.each do |artist|
        if artist.account and artist.event
          inbox = InboxMessage.joins(:request_message).where(
            sender_id: artist.event.creator_id,
            receiver_id: artist.account.id,
            request_messages: {event_id: artist.event.id},
            ).order("inbox_messages.created_at DESC").first

          if inbox and inbox.request_message.expiration_date < DateTime.now
            artist.status = "time_expired"
            artist.save!
            puts "."
          end
        end
      end
    end

    event_venue = VenueEvent.where(status: "request_send")
    puts "venues"

    ActiveRecord::Base.transaction do
      event_venue.each do |venue|
        if venue.account and venue.event
          inbox = InboxMessage.joins(:request_message).where(
            sender_id: venue.event.creator_id,
            receiver_id: venue.account.id,
            request_messages: {event_id: venue.event.id},
            ).order("inbox_messages.created_at DESC").first

          if inbox and inbox.request_message.expiration_date < DateTime.noww
            venue.status = "time_expired"
            venue.save!
          end
        end
      end
    end

    puts " All done now!"
  end
end
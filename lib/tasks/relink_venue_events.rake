namespace :events do
  desc "Change venue_id from account_id to venue"
  task relink_venues: :environment do
    events = Event.where.not(venue_id: nil)
    puts "Going to update #{events.count} events"

    ActiveRecord::Base.transaction do
      events.each do |event|
        account = Account.find(event.venue_id)
        event.venue_id = account.venue_id
        event.save!
        print "."
      end
    end

    puts " All done now!"
  end
end
namespace :events do
  desc "Change artist_number to default"
  task change_artist_number: :environment do
    events = Event.where(artists_number: nil)
    puts "Going to update #{events.count} users"

    ActiveRecord::Base.transaction do
      events.each do |event|
        event.artists_number = 6
        event.save!
        print "."
      end
    end

    puts " All done now!"
  end
end
namespace :events do
  desc "Migrate exact date"
  task migrate_date: :environment do
    events = Event.where(status: "active")
    puts "Going to update #{events.count} events"

    ActiveRecord::Base.transaction do
      events.each do |event|
        event.exact_date_from = event.date_from
        event.exact_date_to = event.date_to
        event.save!
        print "."
      end
    end

    puts " All done now!"
  end
end
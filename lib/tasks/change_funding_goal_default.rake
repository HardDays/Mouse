namespace :events do
  desc "Change funding_goal to default"
  task change_funding_goal: :environment do
    events = Event.all
    puts "Going to update #{events.count} events"

    ActiveRecord::Base.transaction do
      events.each do |event|
        if event.funding_goal == nil
          event.funding_goal = 0
          event.save!
        end
        print "."
      end
    end

    puts " All done now!"
  end
end
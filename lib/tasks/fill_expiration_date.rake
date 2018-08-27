namespace :inbox_messages do
  desc "Fill expiration date for requests"
  task fill_expiration_date: :environment do
    requests = RequestMessage.all
    puts "Going to check #{requests.count} requests"

    ActiveRecord::Base.transaction do
      requests.each do |request|
        request.expiration_date = request.created_at + TimeFrameHelper.to_seconds(request.time_frame)
        request.save

        print "."
      end
    end

    puts " All done now!"
  end
end
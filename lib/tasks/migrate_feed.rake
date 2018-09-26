namespace :feed do
  desc "Migrate feed"
  task migrate_feed: :environment do
    feeds = FeedItem.all
    puts "Going to check #{feeds.count} feed"

    ActiveRecord::Base.transaction do
      feeds.each do |feed|

        if feed.account_update_id
          update = AccountUpdate.where(id: feed.account_update_id).first

          if update
            feed.account_id = update.account_id
            feed.updated_by = update.updated_by
            feed.action = update.action
            feed.field = update.field
            feed.value = update.value
            feed.save!

            print "."
          end

        elsif feed.event_update_id
          update = EventUpdate.where(id: feed.event_update_id).first

          if update
            feed.event_id = update.event_id
            feed.updated_by = update.updated_by
            feed.action = update.action
            feed.field = update.field
            feed.value = update.value
            feed.save!

            print "."
          end
        end
      end
    end

    puts " All done now!"
  end
end
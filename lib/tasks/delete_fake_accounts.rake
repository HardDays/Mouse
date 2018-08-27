namespace :accounts do
  desc "Delete accounts without detalization"
  task delete_fake_accounts: :environment do
    accounts = Account.all
    puts "Going to check #{accounts.count} accounts"

    ActiveRecord::Base.transaction do
      accounts.each do |account|
        if account.account_type == "artist" and account.artist == nil
          account.destroy
        elsif account.account_type == "venue" and account.venue == nil
          account.destroy
        elsif account.account_type == "fan" and account.fan == nil
          account.destroy
        end
        print "."
      end
    end

    puts " All done now!"
  end
end
desc "Set expiration date"
namespace :messages do
  desc "Change expiration date of message"
  task set_expiration_date: :environment do
    request_messages = RequestMessage.where(expiration_date: nil)
    puts "start"

    request_messages.each do |message|
      message.expiration_date = message.created_at + TimeFrameHelper.to_seconds(message.time_frame_range) * message.time_frame_number
    end

    puts " All done now!"
  end
end
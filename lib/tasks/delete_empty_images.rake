namespace :images do
  desc "Destroy empty images"
  task destroy_empty_images: :environment do
    images = Image.where("base64 is null or base64 = ''")
    puts "Going to update #{images.count} images"

    images.each do |image|
      Image.transaction do
        if image.account
          account = image.account
          puts "account #{account.id}"
          image.destroy
        elsif image.event
          event = image.event
          puts "event #{event.id}"
          image.destroy
        elsif image.owner_account
          account = image.owner_account
          puts "owner account #{account.id}"
          image.destroy
        end
      end
    end

    puts "All done now!"
  end
end
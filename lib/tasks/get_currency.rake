desc "This task is called by the Heroku scheduler add-on"
namespace :currency do
  desc "Get current currency for the day"
  task get_for_today: :environment do
    xml = Hash.from_xml(open("http://www.cbr.ru/scripts/XML_daily.asp?date_req=#{DateTime.now.strftime('%d/%m/%Y')}"))

    ValCurs
      Valute
        [0]
          NumCode CharCode Nominal Name Value

    puts " All done now!"
  end
end
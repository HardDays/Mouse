desc "This task is called by the Heroku scheduler add-on"
namespace :currency do
  desc "Get current currency for the day"
  task get_for_today: :environment do
    Currency.destroy_all

    xml = Hash.from_xml(open("http://www.cbr.ru/scripts/XML_daily.asp?date_req=#{DateTime.now.strftime('%d/%m/%Y')}"))

    xml["ValCurs"]["Valute"].inject({}) do |i, value|
      currency = Currency.new
      currency.num_code = value["NumCode"]
      currency.char_code = value["CharCode"]
      currency.nominal = value["Nominal"]
      currency.name = value["Name"]
      currency.value = value["Value"]
      currency.save
    end
    puts " All done now!"
  end
end
class CurrencyHelper

  def self.all
    return [:RUB, :USD, :EUR]
  end

  def self.convert(price, from_currency, to_currency)
    new_currency_value = TodayCurrencyRate.where(char_code: to_currency).first
    old_currency_value = TodayCurrencyRate.where(char_code: from_currency).first

    if new_currency_value
      new_currency_value = new_currency_value.value
    else
      new_currency_value = 1
    end

    if old_currency_value
      old_currency_value = old_currency_value.value
    else
      old_currency_value = 1
    end

    new_price = (price.to_i / new_currency_value) * old_currency_value
    return new_price.round(2)
  end
end
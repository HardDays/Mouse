class CurrencyHelper

  def self.all
    return [:RUB, :USD, :EUR]
  end

  def self.ceil2(price, exp = 0)
    multiplier = 10 ** exp
    ((price * multiplier).ceil).to_f/multiplier.to_f
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
    return self.ceil2(new_price, 2)
  end
end
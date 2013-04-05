module EasyRailsMoney
  module MoneyDslHelper
    def to_currency currency
      return currency if currency.is_a? ::Money::Currency
      ::Money::Currency.new(currency)
    end
    module_function :to_currency
  end
end

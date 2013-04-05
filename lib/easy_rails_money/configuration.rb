require 'active_support/core_ext/module/delegation'

module EasyRailsMoney
  module Configuration
    def configure
      yield self
    end

    # Configuration parameters
    delegate :default_currency=, :to => :Money

    def default_currency
      default =  Money.default_currency
      return default if default.is_a? ::Money::Currency
      return ::Money::Currency.new(default)
    end
  end
end

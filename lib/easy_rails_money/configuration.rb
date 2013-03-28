require 'active_support/core_ext/module/delegation'

module EasyRailsMoney
  module Configuration
    def configure
      yield self
    end

    # Configuration parameters
    delegate :default_currency=, :to => :Money
    delegate :default_currency, :to => :Money
  end
end

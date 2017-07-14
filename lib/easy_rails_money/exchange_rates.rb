require 'multi_json'

module EasyRailsMoney
  module ExchangeRates
    extend ActiveSupport::Concern

    included do
      validates_each :exchange_rate do |record, attribute, value|
        if value.blank?
          record.errors[attribute] << "cannot be blank"
        else
          begin
            # TODO: check for specific exchange rates ie. keys
            unless ActiveSupport::JSON.decode(value).kind_of? Hash
              record.errors[attribute] << "is not a valid exchange rate"
            end
          rescue Object => err
            record.errors[attribute] << "is not a valid json"
          end
        end
      end
    end

    module ClassMethods
      def current_exchange_rate_as_json
        Money.default_bank.export_rates(:json)
      end
    end

    # conventions:
    # database column called exchange_rate which stores it in json
    # accessor is called bank
    def bank
      @bank ||= lambda {
        bank = Money::Bank::VariableExchange.new
        bank.import_rates(:json, self.exchange_rate)
        bank
      }.call
    end

    def with_bank
      old_bank = Money.default_bank
      Money.default_bank = bank
      yield
    ensure
      Money.default_bank = old_bank
    end

    # useful for ActiveModelSerializers
    def exchange_rate_to_hash
      MultiJson.load(exchange_rate, :symbolize_keys => true)
    end

    def exchange_with(amount, currency)
      self.bank.exchange_with(amount, currency)
    end

  end
end

require 'active_support/concern'

module EasyRailsMoney
  module ActiveRecord
    module MoneyDsl
      extend ActiveSupport::Concern

      module ClassMethods
        def money column_name
          money_column = "#{column_name}_money"
          currency_column = "#{column_name}_currency"

          # TODO: test if Memoization will make any difference
          define_method column_name do |*args|
            money = send(money_column)
            currency = send(currency_column) || EasyRailsMoney.default_currency

            if money
              Money.new(money, currency)
            else
              nil
            end
          end

          define_method "#{column_name}=" do |value|
            raise ::ArgumentError unless (value.kind_of?(Money) || value.is_a?(NilClass))

            if value
              currency = EasyRailsMoney.default_currency.id
              currency = value.currency.id

              send("#{money_column}=", value.fractional)
              # it is stored in the database as a string but the Money
              # object exposes it as a Symbol
              send("#{currency_column}=", currency.to_s)

              return value if value.currency
              return Money.new(value.fractional, currency)
            else
              send("#{money_column}=", nil)
              send("#{currency_column}=", nil)
              return nil
            end
          end
            
        end
      end
      
    end
  end
end

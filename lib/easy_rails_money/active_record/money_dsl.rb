require 'active_support/concern'
require "easy_rails_money/money_dsl_helper"

module EasyRailsMoney
  module ActiveRecord
    module MoneyDsl
      extend ActiveSupport::Concern

      included do
        def money_attributes
          attributes.keys.select {|x| x =~ /^(.+)_money/ }.map {|x| x.split('_')[0..-2].join('_') }
        end
      end
      
      module ClassMethods
        attr_accessor :single_currency

        def single_currency?
          # if we define a ActiveRecord object with a money column
          # "before" the table is defined. Then it will throw an error
          # and we will assume that a single currency is defined
          # So always restart the app after the migrations are run
          self.columns_hash.has_key? "currency"
        rescue Object => err
          # leaky abstaction. database adapter is leaking through
          # postgres with activerecord throws an error of type PG::Error and sqlite of ActiveRecord::StatementInvalid
          # so we depend on the message, not the class. still need to test on other
          # database adapters because the message is not exactly the same
          if err.message =~ /Could not find table/ || err.message =~ /relation (.+) does not exist/
            return true
          else
            raise
          end
        end
        
        def with_currency currency, &block
          self.single_currency = EasyRailsMoney::MoneyDslHelper.to_currency(currency).id.to_s
          instance_eval &block
        end

        def new(attributes = nil, options = {})
          instance = super
          # single currency is defined
          if single_currency?
            if attributes && attributes[:currency]
              instance.currency = EasyRailsMoney::MoneyDslHelper.to_currency(attributes[:currency]).id.to_s
            else
              instance.currency = instance.class.single_currency
            end
          end
          instance
        end

        def money column_name
          money_column = "#{column_name}_money"
          currency_column = "#{column_name}_currency"
          single_currency_column = "currency"
          
          if single_currency?
            define_method column_name do |*args|
              money = send(money_column)
              currency = send(single_currency_column)
              
              if money
                Money.new(money, currency)
              else
                nil
              end
            end

            define_method "#{column_name}=" do |value|
              raise ::ArgumentError.new("only Integer or nil accepted") unless (value.kind_of?(Integer) || value.is_a?(NilClass))
              
              send("#{money_column}=", value)
              # currency is stored in a seperate common column
              return Money.new(value, self.currency)
            end # define_method setter

            define_method "currency=" do |value|
              if value.nil?
                money_attributes.map do |name|
                  send "#{name}=", nil
                end
              end
              super value
            end
          else
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
              raise ::ArgumentError.new("only Money or nil accepted") unless (value.kind_of?(Money) || value.is_a?(NilClass))
              
              if value
                send("#{money_column}=", value.fractional)
                # it is stored in the database as a string but the Money
                # object exposes it as a Symbol. so we store it as a
                # String for consistency
                send("#{currency_column}=", value.currency.id.to_s)
                return value
              else
                send("#{money_column}=", nil)
                send("#{currency_column}=", nil)
                return nil
              end
            end # define_method setter
          end
        end # def money
      end # module ClassMethods
      
    end
  end
end



require 'active_support/core_ext/array/extract_options'

module EasyRailsMoney
  # TODO: there are a lot of validations here. customizing the messages
  # for all of them seems cumbersome. if needed write your own. or even patch
  # also while calling the individual validators in validates_money
  # only allow_nil is passed around (as it was needed). test for other
  # like if and unless as well
  class MoneyValidator < ActiveModel::EachValidator

    class << self
      attr_writer :currency_list

      def currency_list
        @currency_list ||= Money::Currency.table.keys.map(&:to_s)
      end
    end
    
    def validate_each(record, attribute, value)
      if options[:allow_nil]
        return if value.nil?
      else
        if value.nil?
          record.errors[attribute] << "cannot be nil" 
          return
        end
      end
      
      if value.fractional < 0
        record.errors[attribute] << "cannot be negative"
      end
    end
  end
end

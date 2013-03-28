require 'active_support/concern'
require 'active_support/core_ext/array/extract_options'

module EasyRailsMoney
  module ActiveRecord
    module MoneyDsl
      extend ActiveSupport::Concern

      module ClassMethods
        def money(field, *args)
          options = args.extract_options!          
        end
      end
      
    end
  end
end

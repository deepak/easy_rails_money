require "easy_rails_money/active_record/money_dsl"
require "easy_rails_money/active_record/migration/schema_statements"
require "easy_rails_money/active_record/migration/table"
require "easy_rails_money/active_record/migration/table_definition"
require "easy_rails_money/money_validator"

ActiveRecord::Base.send :include, EasyRailsMoney::ActiveRecord::MoneyDsl

ActiveRecord::Migration.send :include, EasyRailsMoney::ActiveRecord::Migration::SchemaStatements

ActiveRecord::ConnectionAdapters::TableDefinition.send :include, EasyRailsMoney::ActiveRecord::Migration::TableDefinition
ActiveRecord::ConnectionAdapters::Table.send :include, EasyRailsMoney::ActiveRecord::Migration::Table
  
class ActiveRecord::Base
  def self.validates_money *args
    options = args.extract_options!
    validates_with EasyRailsMoney::MoneyValidator, options.merge(:attributes => args)

    # validates lower-level columns
    args.each do |column_name|
      validates "#{column_name}_money", :numericality => { only_integer: true, greater_than_or_equal_to: 0 }, :allow_nil => options[:allow_nil] 
    end

    allowed_currency = options[:allowed_currency] || Money::Currency.table.keys
    if single_currency?
      validates :currency, :inclusion => { in: allowed_currency }, :allow_nil => options[:allow_nil] 
    else
      args.each do |column_name|
        validates "#{column_name}_currency", :presence => true, :inclusion => { in: allowed_currency }, :allow_nil => options[:allow_nil] 
      end
    end
  end
end

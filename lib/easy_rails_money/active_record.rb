require "easy_rails_money/active_record/money_dsl"
require "easy_rails_money/active_record/migration/schema_statements"
require "easy_rails_money/active_record/migration/table"
require "easy_rails_money/active_record/migration/table_definition"

ActiveRecord::Base.send :include, EasyRailsMoney::ActiveRecord::MoneyDsl

ActiveRecord::Migration.send :include, EasyRailsMoney::ActiveRecord::Migration::SchemaStatements

ActiveRecord::ConnectionAdapters::TableDefinition.send :include, EasyRailsMoney::ActiveRecord::Migration::TableDefinition
ActiveRecord::ConnectionAdapters::Table.send :include, EasyRailsMoney::ActiveRecord::Migration::Table


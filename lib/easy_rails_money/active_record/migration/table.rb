module EasyRailsMoney
  module ActiveRecord
    module Migration
      module Table
        # called for change_table
        # currency and #money defined in TableDefinition

        # Creates one or two columns to represent a Money object in the named table
        #
        # An integer column for storing Money in its base unit
        # eg. cents for a Dollar denomination and a string for storing
        # its currency name. Can think of it as a persisted or serialized
        # Money object in the database. The integer column is suffixed
        # with '_money' to aid in reflection ie. to find all money
        # columns. Likewise the currency column is suffixed with '_currency'
        # If does not create an individual currency column if a
        # common currency column is defined
        #
        # @param column_names [Array|Symbol|String] List of money columns to add
        # @return is not important and can change
        #
        # @note If we have defined a currency column for a record then only the integer column is defined.
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#add_monetize
        # @see EasyRailsMoney::ActiveRecord::Migration::TableDefinition#monetize
        # @see EasyRailsMoney::ActiveRecord::Migration::TableDefinition#currency
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#remove_monetize
        def monetize(column_names, options={})
          Array(column_names).each do |name|
            column "#{name}_money",    :integer, options
            column "#{name}_currency", :string,  options unless has_currency_column?
          end
        end

        # Removes the columns which represent the Money object
        #
        # Removes the two columns added by money. The money amount and
        # the currency column. If there are no remaining money amount columns
        # and a common currency column exists. then it is also removed
        #
        # @param column_names [Array|Symbol|String] List of money columns to remove
        # @return is not important and can change
        #
        # @note If we have defined a currency column for a record then currency column is removed only if no other money column are there
        #
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#remove_monetize
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#add_monetize
        # @see EasyRailsMoney::ActiveRecord::Migration::TableDefinition#currency
        # @note multiple remove_monetize calls are not supported in one migration. because at this point the schema is different from the migration defined
        def remove_monetize(*column_names)
          column_names.each do |name|
            remove "#{name}_money"
            remove "#{name}_currency"
          end
          remove_currency unless has_money_columns?
        end

        # Add a common currency column
        #
        # @return is not important and can change
        #
        # Add a common currency column and remove the individual
        # currrency columns if they exist
        def currency options = {}
          remove_currency_columns
          column :currency, :string, options
        end

        # Removes the common currency column
        #
        # Usually we create an currency column for each money
        # columns. We can have multiple money columns in the same
        # record, in which case we can have a single currency
        # column. This helper removes that common curremcy column. For
        # the existing money column it adds back their currency
        # columns as well. It reflects on the database schema by
        # looking at the column name. By convention the money amount
        # column is prefixed by '_money' and the currency column by '_currency'
        #
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#remove_currency
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#remove_monetize
        # @see EasyRailsMoney::ActiveRecord::Migration::TableDefinition#currency
        def remove_currency
          remove :currency
          money_columns do |money_column|
            column "#{money_column}_currency", "string"
          end
        end

        protected
        def remove_currency_columns
          money_columns do |money_column|
            remove "#{money_column}_currency"
          end
        end

        def columns
          # @base.schema_cache.clear_table_cache! @table_name
          @base.schema_cache.columns(@name).map { |x| x.name }
        end

        def has_currency_column?
          columns.select { |x| x == "currency" }.any?
        end

        def money_columns
          columns.select { |col|
            col =~ /_money/
          }.map { |col|
            name = col.match(/(.+)_money/)[1]
            if block_given?
              yield name
            else
              name
            end
          }
        end

        def has_money_columns?
          money_columns.any?
        end
      end
    end
  end
end

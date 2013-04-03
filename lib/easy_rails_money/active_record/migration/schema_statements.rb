module EasyRailsMoney
  module ActiveRecord
    module Migration
      module SchemaStatements
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
        # @param table_name [Symbol|String]
        # @param column_names [Array|Symbol|String] List of money columns to add
        # @return is not important and can change
        #
        # @note If we have defined a currency column for a record then only the integer column is defined.
        # @see EasyRailsMoney::ActiveRecord::Migration::TableDefinition#money
        # @see EasyRailsMoney::ActiveRecord::Migration::Table#money
        # @see EasyRailsMoney::ActiveRecord::Migration::TableDefinition#currency
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#remove_money
        def add_money table_name, *column_names
          column_names.each do |name|
            add_column table_name, "#{name}_money",    :integer
            add_column table_name, "#{name}_currency", :string unless has_currency_column?(table_name)
          end
        end

        # Removes the columns which represent the Money object
        #
        # Removes the two columns added by add_money. The money amount and
        # the currency column. If there are no remaining money amount columns
        # and a common currency column exists. then it is also removed
        #
        # @param table_name [Symbol|String]
        # @param column_names [Array|Symbol|String] List of money columns to remove
        # @return is not important and can change
        # @note If we have defined a currency column for a record then currency column is removed only if no other money column are there
        #
        # @see EasyRailsMoney::ActiveRecord::Migration::Table#remove_money
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#add_money
        # @see EasyRailsMoney::ActiveRecord::Migration::TableDefinition#currency
        # @note multiple remove_money calls are not supported in one migration. because at this point the schema is different from the migration defined
        def remove_money table_name, *column_names
          column_names.each do |name|
            remove_column table_name, "#{name}_money"
            remove_column table_name, "#{name}_currency"
          end
          remove_currency table_name unless has_money_columns?(table_name)
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
        # @param table_name [Symbol|String]
        #
        # @see EasyRailsMoney::ActiveRecord::Migration::Table#remove_currency
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#remove_money
        # @see EasyRailsMoney::ActiveRecord::Migration::TableDefinition#currency
        def remove_currency table_name
          remove_column table_name, :currency
          money_columns(table_name) do |money_column|
            add_column table_name, "#{money_column}_currency", :string
          end
        end

        protected
        def has_currency_column? table_name
          connection.schema_cache.clear_table_cache! table_name
          connection.schema_cache.columns[table_name].select {|x| x.name == "currency" }.any?
        end

        def money_columns table_name
          # FIXME: see specs tagged
          # fixme_need_to_clear_table_cache. for that test needed to
          # clear the cache
          connection.schema_cache.clear_table_cache! table_name
          connection.schema_cache.columns[table_name].select { |col|
            col.name =~ /_money/
          }.map { |col|
            name = col.name.match(/(.+)_money/)[1]
            if block_given?
              yield name
            else
              name
            end
          }
        end

        def has_money_columns? table_name
          money_columns(table_name).any?
        end
      end
    end
  end
end

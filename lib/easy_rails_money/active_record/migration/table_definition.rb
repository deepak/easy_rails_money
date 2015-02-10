module EasyRailsMoney
  module ActiveRecord
    module Migration
      module TableDefinition
        # called for create_table

        # Adds a common currency column
        #
        # Usually we create an currency column for each money
        # columns. We can have multiple money columns in the same
        # record, in which case we can have a single currency
        # column. This helper creates that common curremcy column
        #
        # @return is not important and can change
        #
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#remove_currency
        def currency options={}
          remove_currency_columns
          column :currency, :string, options
        end

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
        # @see EasyRailsMoney::ActiveRecord::Migration::Table#monetize
        # @see EasyRailsMoney::ActiveRecord::Migration::TableDefinition#currency
        # @see EasyRailsMoney::ActiveRecord::Migration::SchemaStatements#remove_monetize
        def monetize(column_names, options={})
          Array(column_names).each do |name|
            column "#{name}_money",      :integer, options
            unless columns.select { |x| x.name == "currency" }.any?
              column "#{name}_currency", :string,  options
            end
          end
        end

        protected
        def remove_currency_columns
            columns.each do |x|
                remove_column x.name if x.name =~ /_currency/
            end
        end
      end
    end
  end
end

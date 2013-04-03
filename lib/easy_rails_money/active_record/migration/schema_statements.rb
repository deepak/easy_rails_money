module EasyRailsMoney
  module ActiveRecord
    module Migration
      module SchemaStatements
        def add_money table_name, *column_names
          column_names.each do |name|
            add_column table_name, "#{name}_money",    :integer
            add_column table_name, "#{name}_currency", :string unless has_currency_column?(table_name)
          end
        end

        def remove_money table_name, *column_names
          column_names.each do |name|
            remove_column table_name, "#{name}_money"
            remove_column table_name, "#{name}_currency"
          end
          remove_currency table_name unless has_money_columns?(table_name)
        end

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

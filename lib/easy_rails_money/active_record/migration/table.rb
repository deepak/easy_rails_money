module EasyRailsMoney
  module ActiveRecord
    module Migration
      module Table
        # called for change_table
        # currency and #money defined in TableDefinition

        def money(*column_names)
          column_names.each do |name|
            column "#{name}_money",    :integer
            column "#{name}_currency", :string unless has_currency_column?
          end
        end

        def remove_money(*column_names)
          column_names.each do |name|
            remove "#{name}_money"
            remove "#{name}_currency"
          end
          remove_currency unless has_money_columns?
        end

        def currency
          remove_currency_columns
          column :currency, :string
        end

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
          @base.schema_cache.columns[@table_name].map { |x| x.name }
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

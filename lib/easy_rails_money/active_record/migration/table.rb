module EasyRailsMoney
  module ActiveRecord
    module Migration
      module Table
        # called for change_table
        # currency and #money defined in TableDefinition

        def money(*column_names)
          column_names.each do |name|
            column "#{name}_money",      :integer
            unless columns.select { |x| x.name == "currency" }.any?
              column "#{name}_currency", :string
            end
          end
        end

        def currency
          remove_currency_columns
          column :currency, :string
        end

        def remove_money(*column_names)
          column_names.each do |name|
            remove "#{name}_money"
            remove "#{name}_currency"
          end
        end

        def remove_currency
          remove :currency
          money_columns do |money_column|
            column "#{money_column}_currency", "string"
          end
        end

        def remove_currency_columns
          money_columns do |money_column|
            remove "#{money_column}_currency"
          end
        end

        protected
        def columns
          @base.schema_cache.columns[@table_name]
        end

        def money_columns
          columns.select do |col|
            col.name =~ /_money/
          end.map do |col|
            money_column = col.name.match(/(.+)_money/)[1]
            yield money_column
          end
        end

      end
    end
  end
end

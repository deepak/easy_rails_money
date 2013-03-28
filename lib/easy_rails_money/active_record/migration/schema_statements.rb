module EasyRailsMoney
  module ActiveRecord
    module Migration
      module SchemaStatements
        def add_money(table_name, *columns)
          columns.each do |name|
            add_column table_name, name,               :integer
            add_column table_name, "#{name}_currency", :string
          end
        end

        def remove_money(table_name, *columns)
          columns.each do |name|
            remove_column table_name, name
            remove_column table_name, "#{name}_currency"
          end
        end
      end
    end
  end
end

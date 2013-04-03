module EasyRailsMoney
  module ActiveRecord
    module Migration
      module TableDefinition
        # called for create_table
        
        def currency
          remove_currency_columns
          column :currency, :string
        end
        
        def money(*column_names)
          column_names.each do |name|
            column "#{name}_money",      :integer
            unless columns.select { |x| x.name == "currency" }.any?
              column "#{name}_currency", :string
            end
          end
        end

        protected
        def remove_currency_columns
          columns.delete_if { |x| x.name =~ /_currency/ }
        end
        
      end
    end
  end
end

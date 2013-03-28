module EasyRailsMoney
  module ActiveRecord
    module Migration
      module Table
        def money(*columns)
          columns.each do |name|
            column name,               :integer
            column "#{name}_currency", :string
          end
        end

        def remove_money(*columns)
          columns.each do |name|
            remove name,               :integer
            remove "#{name}_currency", :string
          end
        end
      end
    end
  end
end

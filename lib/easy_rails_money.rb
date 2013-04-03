require "money"
require "easy_rails_money/version"
require "easy_rails_money/configuration"

# @author Deepak Kannan
module EasyRailsMoney
  extend Configuration
end

if defined? ActiveRecord
  require "easy_rails_money/active_record"
end

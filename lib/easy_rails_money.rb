# -*- coding: utf-8 -*-

require "money"
require "easy_rails_money/version"
require "easy_rails_money/configuration"

# @author Deepak Kannan
# “Young people, nowadays, imagine that money is everything.  
#   
# Yes, murmured Lord Henry, settling his button-hole in his coat; and when they grow older they know it.”  
# ― Oscar Wilde, The Picture of Dorian Gray and Other Writings  
# This library provides integration of [money](http://github.com/Rubymoney/money) gem with [Rails](https://github.com/rails/rails).
module EasyRailsMoney
  extend Configuration
end

if defined? ActiveRecord
  require "easy_rails_money/active_record"
end

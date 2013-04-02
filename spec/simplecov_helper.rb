require 'simplecov'

SimpleCov.adapters.define 'easy_money_rails' do
  add_filter '/spec/'
  add_group 'migration', '/migration'
end

SimpleCov.start 'easy_money_rails'

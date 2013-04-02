require 'simplecov_helper' if ENV['COVERAGE'] == "on"
require 'active_record'
require_relative '../lib/easy_rails_money'

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

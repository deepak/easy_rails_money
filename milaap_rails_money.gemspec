# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_rails_money/version'

Gem::Specification.new do |gem|
  gem.name          = "milaap_rails_money"
  gem.version       = EasyRailsMoney::VERSION
  gem.authors       = ["Milaap Technology"]
  gem.email         = ["tech@milaap.com"]
  gem.description   = "Integrate Rail's ActiveRecord gem and the money gem. Focus is on a simple code and API"
  gem.summary       = "Integrate Rail's ActiveRecord gem and the money gem"
  gem.homepage      = "https://github.com/Milaap/easy_rails_money"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib", "app/models"]

  gem.add_dependency "rails", "~> 5.0.7.2"
  gem.add_dependency "money",         "~> 6.13.6"
  gem.add_dependency "activesupport", "~> 5.0.7.2"

  gem.add_development_dependency "rake",         "~> 10.0.4"

  # for running tests
  gem.add_development_dependency "rspec",        "~> 2.12"
  # we use an in-memory sqlite database for speed
  gem.add_development_dependency "sqlite3",      "~> 1.3.7"
  # testing against the ActiveRecord interface
  gem.add_development_dependency "activerecord", "~> 5.0.7.2"

  gem.add_development_dependency "pry-byebug"
  gem.add_development_dependency "simplecov",    "~> 0.7.1"

  # for generating docs
  gem.add_development_dependency "yard",         "~> 0.9.9"
  # needed by YARD to read markdown files
  gem.add_development_dependency "redcarpet",    "~> 2.2.2"
end

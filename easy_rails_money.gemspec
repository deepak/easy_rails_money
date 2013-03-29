# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_rails_money/version'

Gem::Specification.new do |gem|
  gem.name          = "easy_rails_money"
  gem.version       = EasyRailsMoney::VERSION
  gem.authors       = ["Deepak Kannan"]
  gem.email         = ["kannan.deepak@gmail.com"]
  gem.description   = "Integrate Rail's ActiveRecord gem and the money gem. Focus is on a simple code and API"
  gem.summary       = "Integrate Rail's ActiveRecord gem and the money gem"
  gem.homepage      = "https://github.com/deepak/easy_rails_money"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "money",         "~> 5.1.1"
  gem.add_dependency "activesupport", "~> 3.2"
  
  gem.add_development_dependency "rspec",        "~> 2.12"
  gem.add_development_dependency "activerecord", "~> 3.2"
  gem.add_development_dependency "sqlite3",      "~> 1.3.7"
  gem.add_development_dependency "debugger",     "~> 1.5.0"
end

class Loan < ActiveRecord::Base
  attr_accessible :name
  money :principal
  money :repaid
  money :npa
end

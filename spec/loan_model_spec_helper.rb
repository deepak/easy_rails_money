class Loan < ActiveRecord::Base
  attr_accessible :name
  money :principal
  money :repaid
  money :amount_funded
end

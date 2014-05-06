class Loan < ActiveRecord::Base
  money :principal
  money :repaid
  money :amount_funded
end

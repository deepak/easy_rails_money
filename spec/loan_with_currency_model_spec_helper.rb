class LoanWithCurrency < ActiveRecord::Base
  self.table_name = "loans"
  attr_accessible :name

  with_currency(:inr) do
    money :principal
    money :repaid
    money :npa
  end
end

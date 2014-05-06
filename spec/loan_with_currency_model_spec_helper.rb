class LoanWithCurrency < ActiveRecord::Base
  self.table_name = "loans"

  with_currency(:inr) do
    money :principal
    money :repaid
    money :amount_funded
  end
end

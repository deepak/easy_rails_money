class LoanWithCurrencyAndValidation < ActiveRecord::Base
  self.table_name = "loans"
  attr_accessible :name

  with_currency(:inr) do
    money :principal
    money :repaid
    money :npa
  end

  validates_money :principal, :repaid, :npa, :allow_nil => true, :allowed_currency => %w[inr usd sgd]
end

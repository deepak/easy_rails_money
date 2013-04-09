require 'spec_helper'
require 'active_record_spec_helper'

# add test that the currency will be serialized in a fixed format
# 
# currency (single or otherwise) is always a string
# and it is in smallcase
# because, Money.default_currency.id == "inr".to_sym
# 
# previously, single_currency was a Money::Currency object
# whereas some_money_currency was a string object
# 
# bugfix: also the currency object was being serialized as a yaml
# which was a bug. facepalm stupid
# 
# this was added so that adding validations are easier
# ie. no need to make a case-insensitive check
# and to fix the above bug
# 
# not very happy. might want to add typecasts

describe "Currency Persistence" do  
  before(:all) do
    currencies = ["inr", # Indian rupee
                  "usd", # USA dollars
                  "aud", # Australian dollar
                  "eur", # Euro
                  "gbp"  # British pound
                 ]
    @currency = currencies.shuffle[0]

    # TODO: how to couple this choice with rspec seed
    # take a random currency so that we do not depend on any one
    # default_currency while testing
    EasyRailsMoney.configure do |c|
      c.default_currency = Money::Currency.new(@currency)
    end
  end
  
  context "individual currency", :wip do
    let(:loan_model) {      
      migrate CreateTableDefinition::CreateLoanWithoutCurrency
      require 'loan_model_spec_helper'
      Loan
    }

    subject {
      loan = loan_model.new
      loan.principal = 100.to_money(@currency)
      loan.repaid    = 50.to_money(@currency)
      loan.npa       = 10.to_money(@currency)
      loan
    }

    it "currency should be capitalized" do            
      subject.save!
      
      expect(subject.principal_currency).to eq @currency
      expect(subject.principal_currency_before_type_cast).to eq @currency
    end

    it "currency should be capitalized for a new object" do
      subject.save!
      loan = loan_model.find subject.id

      expect(subject.principal_currency).to eq @currency
      expect(subject.principal_currency_before_type_cast).to eq @currency
    end
  end
  
  context "single currency" do
    let(:loan_model) {      
      migrate CreateTableDefinition::CreateLoanWithCurrency
      require 'loan_with_currency_model_spec_helper'
      LoanWithCurrency
    }

    subject {
      loan = loan_model.new
      loan.currency = @currency
      loan.principal = 100 * 100
      loan.repaid    = 50 * 100
      loan.npa       = 10 * 100
      loan
    }

    it "currency should be capitalized" do
      subject.save!

      expect(subject.currency).to eq @currency
      expect(subject.currency_before_type_cast).to eq @currency
    end

    it "currency should be capitalized for a new object" do
      subject.save!
      loan = loan_model.find subject.id

      expect(loan.currency).to eq @currency
      expect(loan.currency_before_type_cast).to eq @currency
    end
  end
end

require 'spec_helper'
require 'active_record_spec_helper'
require 'active_support/core_ext/array/extract_options'

# TODO: there are a lot of validations here. customizing the messages
# for all of them seems cumbersome. if needed write your own. or even patch
# also while calling the individual validators in validates_money
# only allow_nil is passed around (as it was needed). test for other
# like if and unless as well
class MoneyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    debugger
    if options[:allow_nil]
      return if value.nil?
    else
      record.errors[attribute] << "cannot be nil" if value.nil?
      return
    end
    
    if value.fractional < 0
      record.errors[attribute] << "cannot be negative"
    end
  end
end

class ActiveRecord::Base
  def self.validates_money *args
    options = args.extract_options!
    validates_with MoneyValidator, options.merge(:attributes => args)

    # validates lower-level columns
    args.each do |column_name|
      validates "#{column_name}_money", :numericality => { only_integer: true, greater_than_or_equal_to: 0 }, :allow_nil => options[:allow_nil] 
    end

    allowed_currency = options[:allowed_currency] || Money::Currency.table.keys
    if single_currency?
      validates :currency, :inclusion => { in: allowed_currency }, :allow_nil => options[:allow_nil] 
    else
      args.each do |column_name|
        validates "#{column_name}_currency", :presence => true, :inclusion => { in: allowed_currency }, :allow_nil => options[:allow_nil] 
      end
    end
  end
end

describe "Validation" do  
  context "single currency" do
    def loan_model
      migrate CreateTableDefinition::CreateLoanWithCurrency
      load 'loan_with_currency_model_spec_helper.rb'
      LoanWithCurrency
    end

    let(:loan) do
      loan_model.instance_eval {
        validates_money :principal, :repaid, :npa, :allow_nil => false, :allowed_currency => %w[inr usd sgd]
      }
      
      loan = loan_model.new
      loan.name = "loan having some values"
      loan.principal = 100 * 100
      loan.repaid    = 50 * 100
      loan.npa       = 10 * 100
      loan
    end

    let(:nil_loan) do
      loan_model.instance_eval {
        validates_money :principal, :repaid, :npa, :allow_nil => true, :allowed_currency => %w[inr usd sgd]
      }
      
      loan = loan_model.new
      loan.name = "loan having nil values"
      loan.principal = nil
      loan.repaid    = nil
      loan.npa       = nil
      loan
    end

    it "is valid when it is a Money object" do
      expect(loan).to be_valid
    end

    it "is valid if currency is nil and allow_nil is true", :wip do
      nil_loan.currency = nil
      expect(nil_loan.attributes["currency"]).to be_nil
      debugger
      expect(nil_loan).to be_valid
    end
    
    it "is in-valid if values are nil and allow_nil is false", :wip do
      loan.principal = nil
      expect(loan).not_to be_valid
      # expect(loan.errors.messages).to eq :principal=>["cannot be nil"], :principal_money=>["is not a number"], :currency=>["is not included in the list"]
    end

    it "is in-valid if currency is nil and allow_nil is false", :fixme do
      loan.currency = nil
      expect(loan.attributes["currency"]).to be_nil
      expect(loan.principal).to be_nil
      expect(loan).not_to be_valid
      # TODO: something funny going-on with the errors messages hash
    end

    pending "check lower-level validations"
  end
end

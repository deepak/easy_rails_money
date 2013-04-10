require 'spec_helper'
require 'active_record_spec_helper'

describe "Validation" do  
  context "single currency" do    
    def loan_model
      Object.send(:remove_const, "LoanWithCurrency") if defined? LoanWithCurrency
      migrate CreateTableDefinition::CreateLoanWithCurrency
      load 'loan_with_currency_model_spec_helper.rb'
      LoanWithCurrency
    end

    # subject can be delayed bound ie. after some changes
    def add_expectations subject, allow_nil      
      expect(subject.class.validators.length).to eq 5
      expect(subject.class.validators.select {|x| x.is_a? EasyRailsMoney::MoneyValidator }.length).to eq 1
      expect(subject.class.validators.map {|x| x.options[:allow_nil] }.uniq).to eq [allow_nil]

      EasyRailsMoney::MoneyValidator.any_instance.should_receive(:validate_each).with(subject, :principal, subject.principal)
      EasyRailsMoney::MoneyValidator.any_instance.should_receive(:validate_each).with(subject, :repaid, subject.repaid)
      EasyRailsMoney::MoneyValidator.any_instance.should_receive(:validate_each).with(subject, :amount_funded, subject.amount_funded)
    end

    context "do not allow nil" do
      let(:subject) do
        model = loan_model
        model.instance_eval {
          validates_money :principal, :repaid, :amount_funded, :allow_nil => false, :allowed_currency => %w[inr usd sgd]
        }
        
        loan = model.new
        loan.name = "loan having some values"
        loan.principal = 100 * 100
        loan.repaid    = 50 * 100
        loan.amount_funded = 10 * 100
        loan
      end

      it "is valid when it is a Money object" do
        add_expectations subject, false
        expect(subject).to be_valid
      end

      it "is in-valid if values are nil and allow_nil is false" do      
        subject.principal = nil
        add_expectations subject, false
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq :principal_money=>["is not a number"]
      end

      it "is in-valid if currency is nil and allow_nil is false"  do
        old = subject.principal
        expect { subject.currency = nil }.to change { subject.principal }.from(old).to(nil) 
        expect(subject.attributes["currency"]).to be_nil
        add_expectations subject, false
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq(:principal_money=>["is not a number"], :repaid_money=>["is not a number"], :amount_funded_money=>["is not a number"], :currency=>["is not included in the list"])
      end
    end # context "do not allow nil"

    context "allow nil", :fixme do
      let(:subject) do
        model = loan_model
        model.instance_eval {
          validates_money :principal, :repaid, :amount_funded, :allow_nil => true, :allowed_currency => %w[inr usd sgd]
        }
        
        loan = model.new
        loan.name = "loan having nil values"
        loan.principal = nil
        loan.repaid    = nil
        loan.amount_funded = nil
        loan
      end
      
      it "is valid if currency is nil and allow_nil is true" do
        subject.currency = nil
        expect(subject.principal).to be_nil
        expect(subject.attributes["currency"]).to be_nil
        
        add_expectations subject, true
        expect(subject).to be_valid
      end

      it "is in-valid if currency is not allowed" do
        subject.currency = "foo"
        add_expectations subject, true
        expect(subject).not_to be_valid
      end
    end # context "allow nil"

    context "no allowed currency" do
      let(:subject) do
        model = loan_model
        model.instance_eval {
          validates_money :principal, :repaid, :amount_funded, :allow_nil => false
        }
        
        loan = model.new
        loan.name = "loan having some values and all currencies allowed"
        loan.principal = 100 * 100
        loan.repaid    = 50 * 100
        loan.amount_funded = 10 * 100
        loan
      end

      it "is valid when it is a Money object" do
        add_expectations subject, false
        expect(subject).to be_valid
      end
    end

    pending "check lower-level validations"
  end
end

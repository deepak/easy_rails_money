require 'spec_helper'
require 'active_record_spec_helper'

class Loan < ActiveRecord::Base
  attr_accessible :name
  money :principal
end

describe "Money DSL" do
  subject { Loan.new }

  before(:all) do
    currencies = [:inr, # Indian rupee
                  :usd, # USA dollars
                  :aud, # Australian dollar
                  :eur, # Euro
                  :gbp  # British pound
                 ]

    # TODO: how to couple this choice with rspec seed
    # take a random currency so that we do not depend on any one
    # default_currency while testing
    EasyRailsMoney.configure do |c|
      c.default_currency = Money::Currency.new(currencies.shuffle[0])
    end
  end

  describe "#money" do
    # validations

    context "individual currency columns" do
      before(:each) do
        migrate CreateTableDefinition::CreateLoanWithoutCurrency
      end

      describe "#getter" do
        it "defines a getter" do
          expect(subject).to respond_to(:principal)
        end

        it "getter returns nil if nothing is set" do
          expect(subject.principal).to eq nil
          expect(subject.principal).to_not eq Money.new(0)
        end

        it "gets the same value as set" do
          money = Money.new(100, "INR")
          expect { subject.principal = money }.to change { subject.principal }.
            from(nil).
            to(money)
        end
      end # describe "#getter"

      describe "#setter=" do
        it "defines a setter" do
          expect(subject).to respond_to(:principal=).with(1).argument
        end

        it "throws an error if we try to set anything other than a Money object or nil" do
          expect { subject.principal = 100 }.to raise_error(ArgumentError)
          expect { subject.principal = nil }.to_not raise_error
        end

        it "returns the same value which is set" do
          money = Money.new(100, "inr")
          expect(subject.principal = money).to eq money
        end

        it "returns a value with the default currency when not given" do
          expect(subject.principal = Money.new(100)).to eq Money.new(100, EasyRailsMoney.default_currency)
        end

        it "can set a value with a different currency" do
          money = Money.new(100, "JPY")
          expect { subject.principal = money }.to change { subject.principal }.
            from(nil).
            to(money)
        end

        context "actually sets the lower-level database columns" do
          it "sets the money column" do
            expect { subject.principal = Money.new(100, :inr) }.to change { subject.principal_money }.
              from(nil).
              to(100)
          end

          it "sets the currency column" do
            expect { subject.principal = Money.new(100, :inr) }.to change { subject.principal_currency }.
              from(nil).
              to("inr")
          end
        end

        context "when nil is set" do
          it "can set to nil" do
            subject.principal = nil
            expect(subject.principal).to eq nil
          end
        end
      end # describe "#setter="
    end # context "individual currency columns"

    context "single currency" do
      before(:each) do
        migrate CreateTableDefinition::CreateLoanWithCurrency
      end

      pending
    end

    pending "validations"
    pending "support multiple fields at once"

  end # describe "#money"
end

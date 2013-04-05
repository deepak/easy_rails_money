require 'spec_helper'
require 'active_record_spec_helper'

describe "Money DSL" do
  subject {
    require 'loan_model_spec_helper'
    Loan.new
  }

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
          expect { subject.principal = nil }.to_not raise_error
          expect { subject.principal = Money.new(100) }.to_not raise_error
          expect { subject.principal = Money.new(100, :usd) }.to_not raise_error
          
          expect { subject.principal = "100" }.to raise_error(ArgumentError)
          expect { subject.principal = 100.10 }.to raise_error(ArgumentError)
          expect { subject.principal = 100 }.to raise_error(ArgumentError)
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

          it "sets the money column when nil" do
            subject.principal = nil
            expect(subject.principal_money).to eq nil
          end

          it "sets the currency column" do
            expect { subject.principal = Money.new(100, :inr) }.to change { subject.principal_currency }.
              from(nil).
              to("inr")
          end

          it "sets the currency column when nil" do
            subject.principal = nil
            expect(subject.principal_currency).to eq nil
          end
        end

        context "when nil is set" do
          it "can set to nil" do
            subject.principal = nil
            expect(subject.principal).to eq nil
          end
        end

        it "cannot set an integer value" do
          expect { subject.principal = 100 }.to raise_error
        end
      end # describe "#setter="
    end # context "individual currency columns"

    context "single currency", :single_currency do
      subject {
        require 'loan_with_currency_model_spec_helper'
        LoanWithCurrency.new
      }

      before(:each) do
        migrate CreateTableDefinition::CreateLoanWithCurrency
      end

      it "sets currency column" do
        expect(subject.currency).to eq ::Money::Currency.new(:inr)
      end

      it "can change single currency on an instance" do
        loan = LoanWithCurrency.new(currency: :usd)
        expect(loan.currency).to eq ::Money::Currency.new(:usd)
        expect(loan.class.single_currency).to eq ::Money::Currency.new(:inr)
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
          expect { subject.principal = 100 }.to change { subject.principal }.
            from(nil).
            to(money)
        end
      end # describe "#getter"

      describe "#setter=" do
        it "defines a setter" do
          expect(subject).to respond_to(:principal=).with(1).argument
        end
        
        it "throws an error if we try to set anything other than a Integer object or nil" do
          expect { subject.principal = nil }.to_not raise_error
          expect { subject.principal = 100 }.to_not raise_error
          
          expect { subject.principal = Money.new(100, "INR") }.to raise_error
          expect { subject.principal = "100" }.to raise_error(ArgumentError)
          expect { subject.principal = 100.10 }.to raise_error(ArgumentError)
        end

        it "returns the same value which is set" do
          expect(subject.principal = 100).to eq 100
        end

        context "actually sets the lower-level database columns" do
          it "sets the money column" do
            expect { subject.principal = 100 }.to change { subject.principal_money }.
              from(nil).
              to(100)
          end

          it "sets the money column when nil" do
            subject.principal = nil
            expect(subject.principal_money).to eq nil
          end

          it "does not set the currency column as it is a common column" do
            expect { subject.principal = 100 }.not_to change { subject.currency }
          end

          it "does not set the currency column when nil as it is a common column" do
            expect { subject.principal = nil }.not_to change { subject.currency }
          end
        end

        context "when nil is set" do
          it "can set to nil" do
            subject.principal = nil
            expect(subject.principal).to eq nil
          end
        end
      end # describe "#setter="
      
    end # context "single currency"

    pending "validations"
    pending "support defining multiple fields at once"
    pending "test the return value of #money. pretty useless though"
    pending "patch create and attributes like #new"
    
  end # describe "#money"
end

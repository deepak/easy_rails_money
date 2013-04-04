require 'spec_helper'

describe "Configuration" do

  describe "#default_currency" do
    let(:existing_currency) { Money::Currency.new(:usd) }
    let(:new_currency) { Money::Currency.new(:inr) }

    it "has a default currency" do
      expect(EasyRailsMoney.default_currency).not_to be_nil
    end

    it "default currency is equal to money's default_currency" do
      expect(EasyRailsMoney.default_currency).to eq Money.default_currency
    end
    
    context "can set and read back the config" do
      before(:each) do
        Money.default_currency = existing_currency
      end
      
      it "sets default currency" do
        expect { EasyRailsMoney.default_currency = new_currency }.
          to change { Money.default_currency }.
          from(existing_currency).
          to(new_currency)
      end

      it "reads default currency" do
        expect { EasyRailsMoney.default_currency = new_currency }.
          to change { EasyRailsMoney.default_currency }.
          from(existing_currency).
          to(new_currency)
      end
    end
  end
  
end

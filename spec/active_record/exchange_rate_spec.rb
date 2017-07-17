require 'spec_helper'
require 'active_record_spec_helper'

class PmtModel
  include ActiveModel::Validations
  include EasyRailsMoney::ExchangeRates

  def exchange_rate
    bank = Money::Bank::VariableExchange.new
    bank.add_rate "USD", "INR", "55"
    bank.add_rate "INR", "USD", "0.01818181818181818"
    bank.export_rates(:json)
  end
end

describe EasyRailsMoney::ExchangeRates do
  let(:payment) { PmtModel.new }

  let!(:bank) do
    bank = Money::Bank::VariableExchange.new
    bank.add_rate "USD", "INR", "60"
    bank.add_rate "INR", "USD", "0.016666666666666666"
    bank
  end

  before(:each) do
    Money.default_bank = bank
  end

  describe "#bank" do
    it "is a kind of Bank" do
      expect(payment.bank).to be_a_kind_of Money::Bank::Base
    end

    it "is serialized from exchange_rate" do
      local_bank = Money::Bank::VariableExchange.new
      local_bank.import_rates(:json, payment.exchange_rate)

      # equality on Bank is not defined on its values. mutex is diff
      # for diff. objects. so is not same
      expect(payment.bank.rates).to eq local_bank.rates
    end
  end # describe "#bank"

  describe "#validates_json_as_string" do
    it "validates that exchange rate is a valid json" do
      expect(payment).to be_valid
    end

    it "validates that exchange rate is an invalid json" do
      payment.instance_eval {
        def exchange_rate
          "1"
        end
      }
      expect(payment).not_to be_valid
    end
  end #describe "#validates_json_as_string"

  describe "#current_exchange_rate_as_json" do
    it "list the current global exchange rate as json" do
      expect(payment.class.current_exchange_rate_as_json).to eq Money.default_bank.export_rates(:json)
    end
  end

  describe "#exchange_rate_to_hash" do
    it "list the exchange rate as a ruby hash" do
      expect(payment.exchange_rate_to_hash).to eq MultiJson.load(payment.exchange_rate, :symbolize_keys => true)
    end
  end

end # describe ExchangeRate

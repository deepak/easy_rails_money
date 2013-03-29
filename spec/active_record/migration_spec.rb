require 'spec_helper'
require 'active_record_spec_helper'
require 'tempfile'

if defined? ActiveRecord

  require 'active_record/schema_dumper'

  class CreateLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans do |t|
          t.string :name
        end
      end
    end
  end

  class AddPrincipalToLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        change_table :loans do |t|
          t.money :principal
        end
      end
    end
  end

  class CreateLoanWithPrincipal < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans do |t|
          t.string :name
        end
        add_money :loans, :principal
      end
    end
  end

  class RemovePrincipalFromLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        remove_money :loans, :principal
      end
    end
  end

  class CreateLoanWithPrincipalUsingTableApi < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans do |t|
          t.string :name
          t.money  :principal
        end
      end
    end
  end

  class RemovePrincipalFromLoanUsingTableApi < ActiveRecord::Migration
    def change
      suppress_messages do
        change_table :loans do |t|
          t.remove_money :principal
        end
      end
    end
  end

  class CreateLoanWithMultipleMoneyColumns < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans, force: true do |t|
          t.string :name
          t.money  :principal
          t.money  :repaid
          t.money  :npa
        end
      end
    end
  end

  class CreateLoanWithSingleCurrencyColumnGivenLast < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans, force: true do |t|
          t.string :name
          t.money  :principal
          t.money  :repaid
          t.money  :npa
          t.currency
        end
      end
    end
  end

  class CreateLoanWithSingleCurrencyColumnGivenFirst < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans, force: true do |t|
          t.string :name
          t.currency
          t.money  :principal
          t.money  :repaid
          t.money  :npa
        end
      end
    end
  end

  class CreateLoanWithSingleCurrencyColumnOrderDoesNotMatter < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans, force: true do |t|
          t.string :name
          t.money  :principal
          t.money  :repaid
          t.currency
          t.money  :npa
        end
      end
    end
  end

  class RemoveCurrencyFromLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        change_table :loans, force: true do |t|
          t.remove_currency
        end
      end
    end
  end

  class AddSingleCurrencyToLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        change_table :loans, force: true do |t|
          t.currency
        end
      end
    end
  end
  
  # class Loan < ActiveRecord::Base   
  #   attr_accessible :principal, :name
  #   # money :principal
  # end
  
  describe "migration" do

    let(:schema_with_principal) do
      <<-EOF.strip_spaces
  create_table "loans", :force => true do |t|
    t.string  "name"
    t.integer "principal_money"
    t.string  "principal_currency"
  end
EOF
    end

    let(:schema_with_only_name) do
      <<-EOF.strip_spaces
  create_table "loans", :force => true do |t|
    t.string  "name"
  end
EOF
    end

    let(:schema_with_single_currency_column) do
      <<-EOF.strip_spaces
  create_table "loans", :force => true do |t|
    t.string  "name"
    t.integer "npa_money"
    t.integer "principal_money"
    t.integer "repaid_money"
    t.string "currency"
  end
EOF
    end

    let(:schema_with_multiple_currency_columns) do
      <<-EOF.strip_spaces
  create_table "loans", :force => true do |t|
    t.string  "name"
    t.string  "npa_currency"
    t.integer "npa_money"
    t.string  "principal_currency"
    t.integer "principal_money"
    t.string  "repaid_currency"
    t.integer "repaid_money"
  end
EOF
    end

    context "schema_statements" do
      before(:each) do
        migrate CreateLoanWithPrincipal
      end

      describe "add_money" do
        it "creates integer column for money and a string column for currency" do
          expect(dump_schema).to eq schema_with_principal
        end
      end
      
      describe "remove_money" do
        it "remove integer column for money and a string column for currency" do        
          expect { migrate RemovePrincipalFromLoan }.to change { dump_schema }.from(schema_with_principal).to(schema_with_only_name)
        end
      end
    end

    context "table_statements" do
      before(:each) do
        migrate CreateLoanWithPrincipalUsingTableApi
      end
      
      describe "add_money" do
        it "creates integer column for money and a string column for currency" do
          expect(dump_schema).to eq schema_with_principal
        end
      end
      
      describe "remove_money" do
        it "remove integer column for money and a string column for currency" do        
          expect { migrate RemovePrincipalFromLoanUsingTableApi }.to change { dump_schema }.from(schema_with_principal).to(schema_with_only_name)
        end
      end
    end

    context "single currency column", :single_currency do
      it "creates integer columns for money and a single string column for currency" do
        migrate CreateLoanWithSingleCurrencyColumnGivenLast
        expect(dump_schema).to eq schema_with_single_currency_column
      end

      context "order does not matter" do
        it "creates integer columns for money and a single string column for currency even when currency column is given first"  do
          migrate CreateLoanWithSingleCurrencyColumnGivenFirst
          expect(dump_schema).to eq schema_with_single_currency_column
        end

        it "creates integer columns for money and a single string column for currency even when currency column is given in between" do
          migrate CreateLoanWithSingleCurrencyColumnOrderDoesNotMatter
          expect(dump_schema).to eq schema_with_single_currency_column
        end
      end

      it "can remove the currency column later" do
        migrate CreateLoanWithSingleCurrencyColumnGivenLast
        expect { migrate RemoveCurrencyFromLoan }.to change { dump_schema }.from(schema_with_single_currency_column).to(schema_with_multiple_currency_columns)
      end

      it "can add a single currrency column later" do
        migrate CreateLoanWithMultipleMoneyColumns
        expect { migrate AddSingleCurrencyToLoan }.to change { dump_schema }.from(schema_with_multiple_currency_columns).to(schema_with_single_currency_column)
      end
    end

    it "can add a money column later" do
      migrate CreateLoan
      expect { migrate AddPrincipalToLoan }.to change { dump_schema }.from(schema_with_only_name).to(schema_with_principal)
    end

  end # describe "migration"
end # if defined? ActiveRecord

require 'spec_helper'
require 'active_record_spec_helper'
require 'tempfile'

class String
  def strip_spaces
    strip.gsub(/\s+/, ' ')
  end
end

if defined? ActiveRecord

  require 'active_record/schema_dumper'

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
  
  # class Loan < ActiveRecord::Base   
  #   attr_accessible :principal, :name
  #   # money :principal
  # end
  
  describe "migration" do

    let(:schema_with_principal) do
      <<-EOF.strip_spaces
  create_table "loans", :force => true do |t|
    t.string  "name"
    t.integer "principal"
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
    
    
  end
end



require 'spec_helper'
require 'active_record_spec_helper'
require 'migration_factory_spec_helper'

describe "Migrating Money columns" do

  let(:schema_with_principal) do
    <<-EOF.strip_spaces
  create_table "loans", :force => true do |t|
    t.string  "name"
    t.integer "principal_money"
    t.string  "principal_currency"
  end
EOF
  end

  let(:schema_with_principal_and_single_currency_column) do
    <<-EOF.strip_spaces
  create_table "loans", :force => true do |t|
    t.string  "name"
    t.integer "principal_money"
    t.string  "currency"
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

  let(:schema_with_constraint) do
    <<-EOF.strip_spaces
  create_table "loans", :force => true do |t|
    t.string  "name"
    t.integer "principal_money", :null => false
    t.string  "currency", :null => false
  end
EOF
  end
  
  context "and testing schema statements", :schema_statements do
    context "which have one currency column for each money column" do
      before(:each) do
        migrate SchemaStatements::CreateLoanAndMoney
      end

      describe "#add_money" do
        it "creates two columns for each money attribute. one to store the lower denomination as an integer and the currency as a string" do
          expect(dump_schema).to eq schema_with_principal
        end
      end

      describe "#remove_money" do
        it "drops two columns for each money attribute. one which stored the lower denomination as an integer and the currency as a string" do
          expect { migrate SchemaStatements::RemovePrincipalFromLoan }.to change { dump_schema }.from(schema_with_principal).to(schema_with_only_name)
        end
      end
    end

    context "which has a single currency", :single_currency do
      before(:each) do
        migrate SchemaStatements::CreateLoanWithCurrency
      end

      describe "#add_money" do
        it "creates one column for each money attribute, to store the lower denomination as an integer. currency is stored in a common column" do
          expect(dump_schema).to eq schema_with_single_currency_column
        end
      end

      describe "#remove_money" do
        it "drops the money column for each money attribute and the common currency column as well", :fixme, :fixme_need_to_clear_table_cache do
          expect { migrate SchemaStatements::RemoveMoneyColumnsFromLoan }.to change { dump_schema }.from(schema_with_single_currency_column).to(schema_with_only_name)
        end

        it "drops the money column for each money attribute but keeps the common currency column because some money columns still remain" do
          expect { migrate SchemaStatements::RemoveMoneyColumnsExceptPrincipalFromLoan }.to change { dump_schema }.
            from(schema_with_single_currency_column).
            to(schema_with_principal_and_single_currency_column)
        end
      end

      describe "#remove_currency" do
        it "drops the common currency column and adds a currency columns to each of the existing money columns" do
          expect { migrate SchemaStatements::RemoveCurrencyFromLoan }.to change { dump_schema }.from(schema_with_single_currency_column).to(schema_with_multiple_currency_columns)
        end

        pending "remove currency while side-by-side adding a money column"
      end
    end
  end # context "schema_statements"

  context "and testing table statements", :table_statements do

    describe "#money" do
      it "can create a schema with not-null constraints on columns", :constraint do
        expect { migrate CreateTableDefinition::CreateLoanWithConstraint }.to change { dump_schema }.from("").to(schema_with_constraint)
      end
    end
    
    context "which have one currency column for each money column" do
      before(:each) do
        migrate CreateTableDefinition::CreateLoanAndMoney
      end
      
      describe "#money" do
        it "creates two columns for each money attribute. one to store the lower denomination as an integer and the currency as a string" do
          expect(dump_schema).to eq schema_with_principal
        end
      end

      describe "#remove_money" do
        it "drops two columns for each money attribute. one which stored the lower denomination as an integer and the currency as a string" do
          expect { migrate ChangeTable::RemovePrincipalFromLoan }.to change { dump_schema }.from(schema_with_principal).to(schema_with_only_name)
        end
      end
    end

    context "which has a single currency", :single_currency do
      describe "#money" do
        context "and tests that order of statements does not matter" do
          it "creates money and common currency cilumns when currency column is specified last" do
            migrate CreateTableDefinition::CreateLoanWithCurrency
            expect(dump_schema).to eq schema_with_single_currency_column
          end
          
          it "creates money and common currency cilumns when currency column is specified first" do
            migrate CreateTableDefinition::CreateLoanWithCurrencySpecifiedFirst
            expect(dump_schema).to eq schema_with_single_currency_column
          end

          it "creates money and common currency cilumns when currency column is specified in-between" do
            migrate CreateTableDefinition::CreateLoanWithCurrencySpecifiedInBetween
            expect(dump_schema).to eq schema_with_single_currency_column
          end
        end
      end

      describe "#remove_money" do
        before(:each) do
          migrate CreateTableDefinition::CreateLoanWithCurrency
        end
        
        it "drops the money column for each money attribute and the common currency column as well" do
          expect { migrate ChangeTable::RemoveMoneyColumnsFromLoan }.to change { dump_schema }.from(schema_with_single_currency_column).to(schema_with_only_name)
        end
        
        it "drops the money column for each money attribute but keeps the common currency column because some money columns still remain" do
          expect { migrate ChangeTable::RemoveMoneyColumnsExceptPrincipalFromLoan }.to change { dump_schema }.
            from(schema_with_single_currency_column).
            to(schema_with_principal_and_single_currency_column)
        end
      end
      
      describe "#remove_currency" do
        it "drops the common currency column and adds a currency columns to each of the existing money columns" do
          migrate CreateTableDefinition::CreateLoanWithCurrency
          expect { migrate ChangeTable::RemoveCurrencyFromLoan }.to change { dump_schema }.from(schema_with_single_currency_column).to(schema_with_multiple_currency_columns)
        end
      end

      it "can add a single currrency column later" do
        migrate CreateTableDefinition::CreateLoanWithoutCurrency
        expect { migrate ChangeTable::AddSingleCurrencyToLoan }.to change { dump_schema }.from(schema_with_multiple_currency_columns).to(schema_with_single_currency_column)
      end
    end # context "which has a single currency"
  end # context "and testing table statements"

  it "can add a money column later" do
    migrate CreateTableDefinition::CreateLoan
    expect { migrate ChangeTable::AddPrincipalToLoan }.to change { dump_schema }.from(schema_with_only_name).to(schema_with_principal)
  end

  pending "separate up and down migration methods. using add_money and remove_money"
end # describe "Migrating Money columns"

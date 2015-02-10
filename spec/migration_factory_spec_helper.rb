# migrations used in tests. our factories/fixtures
# their class names are the same if they are functionally
# equivalent, but are organized in different modules depending on
# whether it is implemented using
# schema_statements, create_table or change_table
module SchemaStatements
  class CreateLoanAndMoney < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans do |t|
          t.string :name
        end
        add_monetize :loans, :principal
      end
    end
  end

  class CreateLoanWithCurrency < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans do |t|
          t.string :name
          t.currency
        end
        add_monetize :loans, :principal, :repaid, :amount_funded
      end
    end
  end

  class RemoveMoneyColumnsFromLoan  < ActiveRecord::Migration
    def change
      suppress_messages do
        remove_monetize :loans, :principal, :repaid, :amount_funded
      end
    end
  end

  class RemoveMoneyColumnsExceptPrincipalFromLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        remove_monetize :loans, :repaid, :amount_funded
      end
    end
  end

  class RemovePrincipalFromLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        remove_monetize :loans, :principal
      end
    end
  end

  class RemoveCurrencyFromLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        remove_currency :loans
      end
    end
  end
end # module SchemaStatements

module ChangeTable
  class AddPrincipalToLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        change_table :loans do |t|
          t.monetize :principal
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

  class RemovePrincipalFromLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        change_table :loans do |t|
          t.remove_monetize :principal
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

  class RemoveMoneyColumnsFromLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        change_table :loans, force: true do |t|
          t.remove_monetize :principal, :repaid, :amount_funded
        end
      end
    end
  end

  class RemoveMoneyColumnsExceptPrincipalFromLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        change_table :loans, force: true do |t|
          t.remove_monetize :repaid, :amount_funded
        end
      end
    end
  end
end # module ChangeTable

module CreateTableDefinition
  class CreateLoan < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans do |t|
          t.string :name
        end
      end
    end
  end

  class CreateLoanAndMoney < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans do |t|
          t.string :name
          t.monetize  :principal
        end
      end
    end
  end

  class CreateLoanWithConstraint < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans, :force => true do |t|
          t.string :name
          t.currency           :null => false
          t.monetize  :principal, :null => false
        end
      end
    end
  end
  
  class CreateLoanWithCurrencySpecifiedFirst < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans, force: true do |t|
          t.string :name
          t.currency
          t.monetize  :principal
          t.monetize  :repaid
          t.monetize  :amount_funded
        end
      end
    end
  end

  class CreateLoanWithCurrencySpecifiedInBetween  < ActiveRecord::Migration
    def change
      suppress_messages do
        create_table :loans, force: true do |t|
          t.string :name
          t.monetize  :principal
          t.monetize  :repaid
          t.currency
          t.monetize  :amount_funded
        end
      end
    end
  end
end # module CreateTableDefinition

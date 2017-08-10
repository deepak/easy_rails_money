class CreateExchangeRates < ActiveRecord::Migration
  def change
    create_table :exchange_rates do |t|
      t.datetime :from_date,      :null=> false
      t.datetime :to_date
      t.string   :from_currency,  :null => false
      t.string   :to_currency,    :null => false
      t.decimal  :value,          :null => false
      t.timestamps null: false
    end
    add_index :exchange_rates, :from_date
    add_index :exchange_rates, :to_date
  end
end

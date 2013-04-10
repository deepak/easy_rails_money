# Changelog

## 0.0.1
- Add a README listing the rationale and rough draft of the migration
  DSL to be implemented
- Added migration DSL to add two columns to persist a money object.
  An Interger column to persist the money amount and a String column
  to persist the currency name

## 0.0.2
- Modify migration DSL to support multiple money amount columns and a
  single currency column
- add travis, codeclimate and gemnasium gem-dependency badges
- has a dependency on ActiveRecord and removed the dependency on Rails

## 0.0.3
- add missing test-cases for supporting a single currency
- refactor tests
- add simplecov coverage report
- Add yard docs and update README

## 0.0.4
- add dsl with_currency for defining a single currency on the model

## 0.0.5
- bugfix: defining a model before the table is created throws an error  
  see spec tagged with `migration`.  
  if we define a ActiveRecord object with a money column  
  "before" the table is defined. Then it will throw  
  an error and we will assume that a single  
  currency is defined. So always restart the app after the  
  migrations are run.  

## 0.0.6
- bugfix: on a bugfix at v0.0.5
  database adapter is leaking through. leaky abstaction
  the error handling for  
  EasyRailsMoney::ActiveRecord::MoneyDsl.single_currency?  
  is dependent on the database adapter being used, which sucks. 
  can test on other database adapters or handle a generic error
  
## 0.0.7
- money and currency column can take options
  activerecord DSL for columns can take options for
  not-null constraints and default. all options are
  passed forward to activerecord

  add_column and change_table do not work for now
  with this syntax

## 0.0.8
- bugfix: single currency was being persisted as a yaml object
- #currency and #some_column_currency are both assigned
  and persisted as a downcase string
  eg. "inr" in the case of Indian Rupee
  so that, Money.default_currency.id == "inr".to_sym
  holds true
  api is changed. previously #currency and #single_currency
  gave a Money::Currency object. now is is a String 

## 0.0.9.pre
- add ActiveRecord::Base.validates_money  
  it validates that currency is in an allowed list  
  and money is stored as a number or can be nil  
- api change: if we set currency (when it is a single currency)  
  as nil. the other money columns are set to nil  
  this is done because technically, Money has a default_currency  
  so we can persist a Money object without the currency  
  but that can change over time and we want to be explicit  
  
## 0.0.9.pre1
- https://github.com/deepak/easy_rails_money/pull/1
  when currency is set to nil, the money columns are set to nil as
  well (see changelog for 0.0.9.pre above)
  that code was buggy. so is a column was named "amount_funded"
  it would give the setter as "amountfunded=" rather than
  "amount_funded=". 
  git sha1: c1d9f6a8160d5a075e78f625f177f6716715c637
- bugfix: validates_money was failing if allowed_currency was not passed
  the syntax is
  validates_money :principal, :repaid, :amount_funded, :allow_nil => false, :allowed_currency => %w[inr usd sgd]
  if we do not pass the last argument allowed_currency then it should
  validate that it is a legal Money::Currency
  that was not happenning because the Rails includes validations
  does not compare Symbols and strings

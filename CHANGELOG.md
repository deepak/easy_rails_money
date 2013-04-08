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

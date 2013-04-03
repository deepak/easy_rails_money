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
- add missing cases for supporting a single currency
- refactor tests
- add simplecov coverage report
- Add yard docs and update README



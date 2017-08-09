# MilaapRailsMoney

Forked from https://github.com/deepak/easy_rails_money

## Installation

Add this line to your application's Gemfile:

    gem 'milaap_rails_money'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install milaap_rails_money

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Usage

### ActiveRecord

Only ActiveRecord is supported for now. And has been tested on
ActiveRecord 3.x

#### Migration helpers

If you want to create a table which has some money columns, then you can use the ```money``` migration helper

```ruby
class CreateLoanWithCurrency < ActiveRecord::Migration
  def change
    create_table :loans, force: true do |t|
      t.string :name
      t.monetize  :principal
      t.monetize  :repaid
      t.monetize  :npa
      t.currency
    end
  end
end
```

If you want to add a money column to an existing table then you can
again use the ```money``` migration helper

```ruby
class AddPrincipalToLoan < ActiveRecord::Migration
  def change
    change_table :loans do |t|
      t.monetize :principal
    end
  end
end
```

Another option is to use ```add_monetize``` migration helper
It is a different DSL style, similar to ```create_table```

```ruby
class AddPrincipalToLoan < ActiveRecord::Migration
  def up
    add_monetize :loans, :principal, :repaid, :npa
  end

  def down
    remove_monetize :loans, :principal, :repaid, :npa
  end
end
```

```add_monetize``` helper is revertable, so you may use it inside ```change``` migrations.
If you writing separate ```up``` and ```down``` methods, you may use
the ```remove_monetize``` migration helper.

The above statements for ```money``` and ```add_monetize``` will create
two columns. An integer column to store the lower denomination as an
integer and a string column to store the currency name.

eg. if we say ```add_monetize :loans, :principal``` Then the following two
columns will be created:
1. integer column called ```principal_money```
2. string column called ```principal_currency```

If we want to store ```$ 100``` in this column then:
1. column ```principal_money``` will contain the unit in the lower denomination
   ie. cents in this case. So for ```$100``` it will store ```100 * 100 => 100_000 cents```
2. column ```principal_currency``` will store the currency name ie. ```usd```

Both the amount and currency is needed to create a ```Money``` object

Now if we have multiple money columns, then you can choose to have a
single currency column

```ruby
class CreateLoanWithCurrency < ActiveRecord::Migration
  def change
    create_table :loans, force: true do |t|
      t.string :name
      t.monetize  :principal
      t.monetize  :repaid
      t.monetize  :npa
      t.currency
    end
  end
end
```

This will create a single column for currency:
1. It creates three columns for each of the money columns
   ```principal_money```, ```repaid_money``` and ```npa_money```
2. note that it does not create a currency column for each of the
   money columns. But a common currency column is created.
   It is boringly enough called ```currency```

Note that columns are prefixed with ```_money``` and ```_currency```
And the common currency column is called ```currency```.

It is used to reflect on the database schema ie. to find out the
money and currency columns defined.
Right now, none of these choices are customizable.

#### Defining the Model

If every money column has its own currency column, then we cn define
the model as:

```ruby
class Loan < ActiveRecord::Base
  attr_accessible :name
  money :principal
  money :repaid
  money :npa
end
```

The corresponding migration (given above) is:

```ruby
class CreateLoanWithCurrency < ActiveRecord::Migration
  def change
    create_table :loans, force: true do |t|
      t.string :name
      t.monetize  :principal
      t.monetize  :repaid
      t.monetize  :npa
    end
  end
end
```

Now if you want a single currency column then:

```ruby
class Loan < ActiveRecord::Base
  attr_accessible :name

  with_currency(:inr) do
    money :principal
    money :repaid
    money :npa
  end
end
```

The corresponding migration (given above) is:

```ruby
class CreateLoanWithCurrency < ActiveRecord::Migration
  def change
    create_table :loans, force: true do |t|
      t.string :name
      t.monetize  :principal
      t.monetize  :repaid
      t.monetize  :npa
      t.currency
    end
  end
end
```

For such a record, where the single currency is defined. calling
currency on a new record will give us the currency. And can define a
common currency per-record while creating it

eg:
```ruby
class Loan < ActiveRecord::Base
  attr_accessible :name

  with_currency(:inr) do
    money :principal
    money :repaid
    money :npa
  end
end

loan = Loan.new
loan.currency # equals Money::Currency.new(:inr)

loan_usd = Loan.new(currency: :usd)
loan_usd.currency # equals Money::Currency.new(:usd)
```

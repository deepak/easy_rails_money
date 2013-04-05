[![Build Status](https://travis-ci.org/deepak/easy_rails_money.png?branch=master)](https://travis-ci.org/deepak/easy_rails_money)
[![Dependency Status](https://gemnasium.com/deepak/easy_rails_money.png)](https://gemnasium.com/deepak/easy_rails_money)
[![Code Climate](https://codeclimate.com/github/deepak/easy_rails_money.png)](https://codeclimate.com/github/deepak/easy_rails_money)

### Under Development

The migration helpers are functionally complete.
Working on integrating with Rails' ActiveModel

# EasyRailsMoney

> “Young people, nowadays, imagine that money is everything.
> 
> Yes, murmured Lord Henry, settling his button-hole in his coat; 
> and when they grow older they know it.”  
> ― Oscar Wilde, The Picture of Dorian Gray and Other Writings

This library provides integration of [money](http://github.com/Rubymoney/money) gem with [Rails](https://github.com/rails/rails).

[money-rails](https://github.com/RubyMoney/money-rails) is much more
popular and full-featured. Definately try it out. I have actually
submitted a PR to that project and it is actively maintained.

I have tried to create a simpler version of [money-rails](https://github.com/RubyMoney/money-rails)
With a better API and database schema, in my opinion
I created this project to scratch my itch.

Please open a new issue [in the github project issues tracker](http://github.com/deepak/easy_rails_money/issues). You are also
more than welcome to contribute to the project :-)  

## Credits

Have stolen lots of code from [money-rails](https://github.com/RubyMoney/money-rails)  
But database schema, API and tests are written from scratch  

## Installation

Add this line to your application's Gemfile:

    gem 'easy_rails_money'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_rails_money

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Rationale

Let us say you want to store a Rupee Money object in the database

```ruby
principal = Money.new(100, "inr")
```  

To serialize the values in the database
Option 1:
```ruby
class CreateLoan < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.integer       :principal_money
      t.string        :principal_currency
    end
  end
end
```

Option 2:
Another option would be
```ruby
class CreateLoan < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.integer       :principal_as_paise
    end
  end
end
```

Note that we are storing the base unit in the database. If the amount
is in dollars we store in cents or if the amount is in Indian Rupees
we store in paise and so on. This is done because FLoats do not have a
accurate representation but Integers do. Can store BigDecimal as well
but it is slower. This is why the Money gem stores amounts as integer  

Watch [Rubyconf 2011 Float-is-legacy](http://www.confreaks.com/videos/698-rubyconf2011-float-is-legacy) for more details
and read [What Every Computer Scientist Should Know About
Floating-Point Arithmetic, by David Goldberg, published in March,
1991](http://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html)  

We have encoded the currency in the column name. I like it because
there is no need to define another column and it is simple. But the
disadvantage is that it is inflexible ie. cannot store two currencies
and changing the column name in MySQL might require downtime for a big table

So let us go with the first option. The disadvantage is that currency
is stored as a string. Integer might be better for storing in the database

Now let us say we want to store multiple columns:

```ruby
principal = Money.new(100, "inr")
repaid    = Money.new(20, "inr")
npa       = Money.new(10, "inr")
```  

Now we would represent it as

```ruby
class CreateLoan < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.integer       :principal_money
      t.string        :principal_currency
      t.integer       :repaid_money
      t.string        :repaid_currency
      t.integer       :npa_money
      t.string        :npa_currency
    end
  end
end
```

We are repeating ourself and mostly all currencies for a record will be
the same. So we can configure the currency on a per-record basis and write

Option 3:
```ruby
class CreateLoan < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.string        :currency
      t.integer       :principal_money
      t.integer       :repaid_money
      t.integer       :npa_money
    end
  end
end
```

It might be possible that we set a currency once for the whole app and
never change it. But this seems like a nice tradeoff api-wise

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
      t.money  :principal
      t.money  :repaid
      t.money  :npa
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
      t.money :principal
    end
  end
end
```

Another option is to use ```add_money``` migration helper
It is a different DSL style, similar to ```create_table```

```ruby
class AddPrincipalToLoan < ActiveRecord::Migration
  def up
    add_money :loans, :principal, :repaid, :npa
  end

  def down
    remove_money :loans, :principal, :repaid, :npa
  end
end
```

```add_money``` helper is revertable, so you may use it inside ```change``` migrations.
If you writing separate ```up``` and ```down``` methods, you may use
the ```remove_money``` migration helper.

The above statements for ```money``` and ```add_money``` will create
two columns. An integer column to store the lower denomination as an
integer and a string column to store the currency name. 

eg. if we say ```add_money :loans, :principal``` Then the following two
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
      t.money  :principal
      t.money  :repaid
      t.money  :npa
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

## TODO's
1. Proof-read docs
2. currency is stored as a string. Integer might be better for storing in the database
3. store a snapshot of the exchange rate as well when the record was
   inserted or if we want to "freeze" the exchange rate per-record
4. specs for migration test the same thing in multiple ways. have a
   spec helper
5. add Gemfil to test on ActiveRecord 4.x ie. with Rails4 . Add to travis.yml as well
6. configure the ```_money``` and ```_currency``` prefix and the name
   of the common ```currency``` column
7. check specs tagged as "fixme"
8. cryptographically sign gem
9. test if Memoization in ```MoneyDsl#money`` will make any difference
   and add a performance test to catch regressions
10. The accessors right now expect a Money object or nil. code and DSL to
    convert String to a currency object. how to specify currency then ?

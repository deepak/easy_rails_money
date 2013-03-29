Under Development. only the migration part is done now

# EasyRailsMoney

This library provides integration of [money](http://github.com/Rubymoney/money) gem with Rails.

Use 'money' to specify which fields you want to be backed by a Money
object

[money-rails](https://github.com/RubyMoney/money-rails) is much more
popular and full-featured. Definately try it out. I have actually
submitted a PR to that project and it is actively maintained.

I have tried to create a simpler version of [money-rails](https://github.com/RubyMoney/money-rails)
With a better API and database schema, in my opinion
I created this project to scratch my itch.

Have stolen lots of code from [money-rails](https://github.com/RubyMoney/money-rails)
API and tests are written from scratch

## How it works

Let us say you want to store a Rupee Money object in the database

```ruby
principal = Money.new(100, "inr")
```  

Option 1:
```ruby
class CreateLoan < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.integer       :principal
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

We have encoded the currency in the column name. I like it because
there is no need to define another column and it is simple. But the
disadvantage is that it is inflexible and changing the column name in
MySQL might require downtime for a big table

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
      t.integer       :principal
      t.string        :principal_currency
      t.integer       :repaid
      t.string        :repaid_currency
      t.integer       :npa
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
      t.integer       :principal
      t.integer       :repaid
      t.integer       :npa
    end
  end
end
```

It might be possible that we set a currency once for the whole app and
never change it. But this seems like a nice tradeoff api-wise

### TODO's
1. currency is stored as a string. Integer might be better for storing in the database
2. store a snapshot of the exchange rate as well when the record was
   inserted or if we want to "freeze" the exchange rate per-record

## Installation

Add this line to your application's Gemfile:

    gem 'easy_rails_money'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_rails_money

## Usage

### ActiveRecord

Only ActiveRecord is supported for now

#### Migration helpers

If you want to add money field to product model you may use ```add_money``` helper

```ruby
class MonetizeLoan < ActiveRecord::Migration
  def change
    add_money :loans, :principal

    # OR

    change_table :products do |t|
      t.money :principal
    end
  end
end
```

```add_money``` helper is revertable, so you may use it inside ```change``` migrations.
If you writing separate ```up``` and ```down``` methods, you may use ```remove_money``` helper.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

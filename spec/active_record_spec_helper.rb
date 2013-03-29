class String
  def strip_spaces
    strip.gsub(/\s+/, ' ')
  end
end

module DumpSchemaHelpers
  # we have a single canonical representation for testing
  # different migrations insert the currency column in different
  # places. but for representation we would like it at the end
  # also the money and currency columns are represented as following
  # each other. eg.
  # t.string "principal_currency"
  # t.string "principal_currency"
  def canonical_representation schema
    schema = schema.strip.split("\n")
    return "" if schema.blank?

    schema = move_currency_column_last schema
    schema = interleave_money_and_currency_columns schema

    schema.join('').strip_spaces
  end
  module_function :canonical_representation

  def interleave_money_and_currency_columns schema
    money_columns = schema.select {|x| x =~ /_money/ }
    currency_columns = schema.select {|x| x =~ /_currency/ }

    schema.delete_if {|x| x =~ /_money/ }
    schema.delete_if {|x| x =~ /_currency/ }

    schema[0..1] +
      (money_columns + currency_columns).sort_by { |x| x.match(/t\.(.+)\"(?<logical_column>.+)_(money|currency).+/)[:logical_column] } +
      schema[2..-1]
  end
  module_function :interleave_money_and_currency_columns

  def move_currency_column_last schema
    currency_column = "    t.string  \"currency\""

    unless schema.select {|x| x == currency_column }.empty?
      schema.delete_if {|x| x == currency_column }
      last = schema.pop
      schema.push currency_column
      schema.push last
    end
    schema
  end
  module_function :move_currency_column_last
end

module SchemaHelpers
  def dump_schema
    Tempfile.open('schema', encoding: "utf-8") do |schema_file|
      ActiveRecord::SchemaDumper.send(:new, ActiveRecord::Base.connection).send(:tables, schema_file)
      schema_file.rewind
      DumpSchemaHelpers.canonical_representation schema_file.read
    end
  end

  def create_ar_connection
    conn = { :adapter => 'sqlite3', :database => ':memory:' }

    begin
      ActiveRecord::Base.establish_connection(conn)
      ActiveRecord::Base.connection
    rescue Exception => e
      $stderr.puts e, *(e.backtrace)
      $stderr.puts "Couldn't create database for #{conn.inspect}"
      return
    end
  end

  def migrate klass
    klass.migrate(:up)
  end
end

module ActiveRecord
  class Migration
    def announce(message)
      # noop
    end
  end
end

RSpec.configure do |c|
  c.include SchemaHelpers

  c.before(:each) do
    create_ar_connection
  end
end

module SchemaHelpers
  def dump_schema
    Tempfile.open('schema', encoding: "utf-8") do |schema_file|
      ActiveRecord::SchemaDumper.send(:new, ActiveRecord::Base.connection).send(:tables, schema_file)
      schema_file.rewind
      schema_file.read.strip_spaces
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

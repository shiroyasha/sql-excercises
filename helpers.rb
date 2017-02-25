require "sqlite3"
require "securerandom"
require "minitest"
require 'minitest/autorun'
require 'minitest/hooks/test'
require "terminal-table"

def create_db(db_name:, tables_file:, data_file:)
  path = "/tmp/dummy_tables/#{db_name}-#{SecureRandom.uuid}.db"

  `mkdir -p #{File.dirname(path)}`

  db = SQLite3::Database.new(path)

  db.execute_batch(File.read(tables_file))
  db.execute_batch(File.read(data_file))

  db
end

def dump(db, table)
  table_sql = db.execute <<-SQL
    SELECT sql
    FROM sqlite_master
    WHERE tbl_name = '#{table}' AND type = 'table'
  SQL

  columns = table_sql[0][0].split("\n")[1..-2]
                           .map(&:strip)
                           .map { |s| s.split(" ").first }
                           .reject { |column| column =~ /CONSTR/ }

  rows = db.execute("SELECT * FROM #{table}")

  table = Terminal::Table.new :rows => rows, :headings => columns

  puts ""
  puts table
end

class Excercise < MiniTest::Unit::TestCase
  include Minitest::Hooks
end

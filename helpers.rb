require "sqlite3"
require "securerandom"
require "minitest"
require 'minitest/autorun'
require 'minitest/hooks/test'

def create_db(db_name:, tables_file:, data_file:)
  path = "/tmp/dummy_tables/#{db_name}-#{SecureRandom.uuid}.db"

  `mkdir -p #{File.dirname(path)}`

  db = SQLite3::Database.new(path)

  puts "[1] DB created. #{path}"

  db.execute_batch(File.read(tables_file))
  puts "[2] DB tables created."

  db.execute_batch(File.read(data_file))
  puts "[3] Sample data inserted."

  db
end

class Excercise < MiniTest::Unit::TestCase
  include Minitest::Hooks
end

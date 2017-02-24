require_relative "../helpers"

class ComputerStore < Excercise
  def before_all
    @db = create_db(
      :db_name => "01_computer_store",
      :tables_file => "01_computer_store/tables.sql",
      :data_file => "01_computer_store/sample_data.sql"
    )
  end

  # Select the names of all the products in the store
  def test_excercise1
    result = @db.execute("SELECT Name FROM Products")

    assert result.include?(["Memory"])
  end

  # Select the names and the prices of all the products in the store
  def test_excercise2
    result = @db.execute("SELECT Name, Price FROM Products")

    assert result.include?(["Hard drive", 240.0])
  end

end

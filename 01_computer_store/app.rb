require_relative "../helpers"

class ComputerStore < Excercise
  def setup
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

  # Select the name of the products with a price less than or equal to $200
  def test_excercise3
    result = @db.execute("SELECT Name FROM Products WHERE Price <= 200")

    refute result.include?(["Hard drive"])
    assert result.include?(["Memory"])
    assert result.include?(["ZIP drive"])
  end

  # Select all the products with a price between $60 and $120
  def test_excercise4
    result = @db.execute("SELECT Name FROM Products WHERE Price <= 200 AND Price >= 60")

    refute result.include?(["Hard drive"])
    refute result.include?(["Floppy disk"])

    assert result.include?(["Memory"])
    assert result.include?(["ZIP drive"])
  end

  # Select the name and price in cents (i.e., the price must be multiplied by 100)
  def test_excercise5
    result = @db.execute("SELECT Name, Price * 100 From Products")

    assert result.include?(["Hard drive", 24000.0])
  end

  # Compute the average price of all the products.
  def test_excercise6
    result = @db.execute("SELECT AVG(Price) From Products")

    assert_equal result, [[154.1]]
  end

  # Compute the average price of all products with manufacturer code equal to 2.
  def test_excercise7
    result = @db.execute("SELECT AVG(Price) From Products WHERE Manufacturer = 2")

    assert_equal result, [[150.0]]
  end

  # Compute the number of products with a price larger than or equal to $180.
  def test_excercise8
    result = @db.execute("SELECT COUNT(Price) From Products WHERE Price >= 180")

    assert_equal result, [[5]]
  end

  # Select the name and price of all products with a price larger than or equal to $180,
  # and sort first by price (in descending order), and then by name (in ascending order)
  def test_excercise9
    result = @db.execute("SELECT Name, Price From Products WHERE Price >= 180 ORDER BY Price DESC, Name")

    assert_equal result, [["Printer", 270.0], ["Hard drive", 240.0], ["Monitor", 240.0], ["DVD burner", 180.0], ["DVD drive", 180.0]]
  end

  # Select all the data from the products, including all the data for each product's manufacturer.
  def test_excercise10
    result = @db.execute("SELECT * From Products INNER JOIN Manufacturers ON Products.Manufacturer = Manufacturers.Code")

    assert result.include?([1, "Hard drive", 240.0, 5, 5, "Fujitsu"])
    assert result.include?([2, "Memory", 120.0, 6, 6, "Winchester"])
  end

  # Select the product name, price, and manufacturer name of all the products.
  def test_excercise11
    result = @db.execute <<-SQL
      SELECT Products.Name, Products.Price, Manufacturers.Name
      FROM Products INNER JOIN Manufacturers ON Products.Manufacturer = Manufacturers.Code
    SQL

    assert result.include?(["Hard drive", 240.0, "Fujitsu"])
    assert result.include?(["Memory", 120.0, "Winchester"])
  end

  # Select the average price of each manufacturer's products, showing only the manufacturer's code.
  def test_excercise12
    result = @db.execute <<-SQL
      SELECT Manufacturer, AVG(PRICE) FROM Products GROUP BY Manufacturer
    SQL

    assert_equal result, [[1, 240.0], [2, 150.0], [3, 168.0], [4, 150.0], [5, 240.0], [6, 62.5]]
  end

  # Select the average price of each manufacturer's products, showing the manufacturer's name
  def test_excercise13
    result = @db.execute <<-SQL
      SELECT Manufacturers.Name, AVG(Products.Price)
      FROM Products INNER JOIN Manufacturers ON Products.Manufacturer = Manufacturers.Code
      GROUP BY Manufacturer
    SQL

    assert_equal result, [["Sony", 240.0], ["Creative Labs", 150.0],
                          ["Hewlett-Packard", 168.0], ["Iomega", 150.0],
                          ["Fujitsu", 240.0], ["Winchester", 62.5]]
  end

  # Select the names of manufacturer whose products have an average price larger than or equal to $150
  def test_excercise14
    result = @db.execute <<-SQL
      SELECT Manufacturers.Name, AVG(Products.Price)
      FROM Products INNER JOIN Manufacturers ON Products.Manufacturer = Manufacturers.Code
      GROUP BY Manufacturer
      HAVING AVG(Products.Price) >= 150
    SQL

    assert_equal result, [["Sony", 240.0], ["Creative Labs", 150.0],
                          ["Hewlett-Packard", 168.0], ["Iomega", 150.0], ["Fujitsu", 240.0]]
  end

  # Select the name and price of the cheapest product.
  def test_excercise15
    result = @db.execute <<-SQL
      SELECT Name, Price FROM Products ORDER BY Price LIMIT 1
    SQL

    assert_equal result, [["Floppy disk", 5.0]]
  end

  # Select the name of each manufacturer along with the name and price of its most expensive product.
  def test_excercise16
    result = @db.execute <<-SQL
      SELECT Manufacturers.Name, Products.Name, Products.Price
      FROM Products INNER JOIN Manufacturers
        ON Products.Manufacturer = Manufacturers.Code
        AND Products.Price = (
          SELECT MAX(Products.Price) FROM Products WHERE Products.Manufacturer = Manufacturers.Code
        )
    SQL

    assert_equal result, [["Fujitsu", "Hard drive", 240.0], ["Winchester", "Memory", 120.0],
                          ["Iomega", "ZIP drive", 150.0], ["Sony", "Monitor", 240.0],
                          ["Creative Labs", "DVD drive", 180.0], ["Hewlett-Packard", "Printer", 270.0],
                          ["Creative Labs", "DVD burner", 180.0]]
  end

  # Add a new product: Loudspeakers, $70, manufacturer 2
  def test_excercise17
    @db.execute <<-SQL
      INSERT INTO Products(Name, Price, Manufacturer) VALUES("Loudspeakers", 70, 2)
    SQL

    result = @db.execute "SELECT Name, Price, Manufacturer FROM Products"

    assert result.include?(["Loudspeakers", 70.0, 2])
  end

  # Update the name of product 8 to "Laser Printer"
  def test_excercise18
    result = @db.execute "SELECT Name FROM Products WHERE Code = 8"
    assert_equal result, [["Printer"]]

    @db.execute <<-SQL
      UPDATE Products SET Name = "Laser Printer" WHERE Code = 8
    SQL

    result = @db.execute "SELECT Name FROM Products WHERE Code = 8"
    assert_equal result, [["Laser Printer"]]
  end

  # Apply a 10% discount to all products
  def test_excercise19
    result = @db.execute "SELECT Price FROM Products"
    assert_equal result, [[240.0], [120.0], [150.0], [5.0], [240.0], [180.0], [90.0], [270.0], [66.0], [180.0]]

    @db.execute <<-SQL
      UPDATE Products SET Price = Products.Price * 0.9
    SQL

    result = @db.execute "SELECT Price FROM Products"
    assert_equal result, [[216.0], [108.0], [135.0], [4.5], [216.0], [162.0], [81.0], [243.0], [59.4], [162.0]]
  end

  # Apply a 10% discount to all products with a price larger than or equal to $120
  def test_excercise20
    result = @db.execute "SELECT Price FROM Products"
    assert_equal result, [[240.0], [120.0], [150.0], [5.0], [240.0], [180.0], [90.0], [270.0], [66.0], [180.0]]

    @db.execute <<-SQL
      UPDATE Products SET Price = Products.Price * 0.9 WHERE Price >= 120
    SQL

    result = @db.execute "SELECT Price FROM Products"
    assert_equal result, [[216.0], [108.0], [135.0], [5.0], [216.0], [162.0], [90.0], [243.0], [66.0], [162.0]]
  end

end

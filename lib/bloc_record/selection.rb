require 'sqlite3'

module Selection
  def find(*ids)
    # todo :implement rejected id array
    ids.select { |id| id.is_a? Integer && id > 0 }

    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end

  def find_one(id)
    if id.is_a? Integer && id > 0
      row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id = #{id};
      SQL
      # get_first_row is method from sqlite3 for obtaining the first row of a result set, and discarding all others. It is otherwise identical to #execute.
      init_object_from_row(row)
    else
      raise ArgumentError.new("Please enter a valid ID...must be a positive whole number.")
    end
  end

  def find_by(attribute, value)
    if columns.include?(attribute)
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
      SQL

      rows_to_array(rows)
    else
      raise ArgumentError.new("#{attribute} is not a valid attribute. Please try again.")
    end
  end

  def take(num=1)
    if num.is_a? Integer && num > 0
      if num > 1
        rows = connection.execute <<-SQL
          SELECT #{columns.join ","} FROM #{table}
          ORDER BY random()
          LIMIT #{num};
        SQL

        rows_to_array(rows)
      else
        take_one
      end
      raise ArgumentError.new("That is not a valid ID...must be a positive whole number.")
    end
  end

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id ASC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id DESC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table};
    SQL

    rows_to_array(rows)
  end

  def find_each(options = {})
    start = options[:start] || 0
    batch_size = options[:batch_size] || 100

    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{batch_size} OFFSET #{start};
    SQL

    rows.each do |row|
      yield init_object_from_row(row)
    end
  end

  def find_in_batches(options = {})
    start = options[:start] || 0
    batch_size = options[:batch_size] || 100

    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{batch_size} OFFSET #{start};
    SQL

    rows_to_array(rows)
  end

  def method_missing(method, *args)
    attribute = method.to_s
    attribute.slice!("find_by_")
    find_by(attribute, args[0])
  end


  private

  def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
        new(data)
    end
  end

  def rows_to_array(rows)
    rows.map { |row| new(Hash[columns.zip(row)]) }
  end

end

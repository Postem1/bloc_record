require 'sqlite3'
require 'bloc_record/utility'

module Schema

  # retrieve the SQL table name
  def table
    BlocRecord::Utility.underscore(name)
  end

  def schema
    unless @schema
      @schema = {}
      connection.table_info(table) do |col|
        # table_info returns information about table.
        # Yields each row of table information if a block is provided.
        @schema[ col["name"] ] = col["type"]
      end
    end
    @schema
  end

  def columns
    schema.keys
  end

  def attributes
    columns - ["id"]
  end

  def count
    connection.execute(<<-SQL)[0][0]
      SELECT COUNT(*) FROM #{table}
    SQL
      # execute is a SQLite3::Database instance method that takes a SQL statement and returns an array of rows (records), each of which contains an array of columns.
      # [0][0] extracts the first column of the first row, which will contain the count.
  end


end

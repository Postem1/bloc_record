require 'sqlite3'

module Selection
  def find(id)
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE id = #{id};
    SQL
      # get_first_row is method from sqlite3 for obtaining the first row of a result set, and discarding all others. It is otherwise identical to #execute.
    data = Hash[columns.zip(row)]
    new(data)
  end
end

require 'sqlite3'
require 'bloc_record/schema'

module Persistence
  def self.included(base)
    # The self.included function is called when the module is included.
    # It allows methods to be executed in the context of the base (where the module is included).
    base.extend(ClassMethods)
  end

  def save
    self.save! rescue false
  end

  def save!
    unless self.id
      self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
      BlocRecord::Utility.reload_obj(self)
      return true
    end

    fields = self.class.attributes.map { |col|            "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")

    self.class.connection.execute <<-SQL
      UPDATE #{self.class.table}
      SET #{fields}
      WHERE id = #{self.id};
    SQL

    true
  end

  module ClassMethods
    def create(attrs)
      # attrs is a hash passed in to the create method
      attrs = BlocRecord::Utility.convert_keys(attrs)
      attrs.delete "id"
      vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }
        # attributes is an array of the column names...defined in schema.rb
      connection.execute <<-SQL
        INSERT INTO #{table} (#{attributes.join ","})
        VALUES (#{vals.join ","});
      SQL

      data = Hash[attributes.zip attrs.values]
      data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
      new(data)
      # pass the hash to new which creates a new object.
    end
  end
end

  # a = ["a", "b", "c"]
  # b = [1, 2, 3]
  # a.zip(b)
  # => [["a", 1], ["b", 2], ["c", 3]]

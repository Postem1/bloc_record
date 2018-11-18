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
    # If an error occurs returns false.  Save unsuccessful.
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

  def update_attribute(attribute, value) # Update One Attribute of an Instance
    self.class.update(self.id, { attribute => value })
  end

  def update_attributes(updates) # Update Multiple Attributes of an Instance
    self.class.update(self.id, updates)
  end

  def method_missing(m, *args)
    attribute = m.to_s
    attribute.slice!("update_")
    update_attribute(attribute, args[0])
  end

  def destroy
    self.class.destroy(self.id)
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

    def update(ids, updates) # updates multiple attributes

      # update multiple records
      if ids.class == Array && updates.class == Array
        ids.each_with_index { |val, index| update(val, updates(index)) }
        true
      end

      updates = BlocRecord::Utility.convert_keys(updates)
      updates.delete "id"

      updates_array = updates.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }

      if ids.class == Fixnum
        where_clause = "WHERE id = #{ids};"
      elsif ids.class == Array
        where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
      else
        where_clause = ";"
      end

      connection.execute <<-SQL
        UPDATE #{table}
        SET #{updates_array * ","} #{where_clause}
      SQL

      true
    end

    def update_all(updates)
       update(nil, updates)
    end

    def destroy(*id)
      if id.length > 1
        where_clause = "WHERE id IN (#{id.join(",")});"
      else
        where_clause = "WHERE id = #{id.first};"
      end

      connection.execute <<-SQL
        DELETE FROM #{table} #{where_clause}
      SQL

      true
    end

    def destroy_all(conditions_hash=nil)
      if conditions_hash && !conditions_hash.empty?
        conditions_hash = BlocRecord::Utility.convert_keys(conditions_hash)
        conditions = conditions_hash.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")

        connection.execute <<-SQL
          DELETE FROM #{table}
          WHERE #{conditions};
       SQL
      else
        connection.execute <<-SQL
          DELETE FROM #{table}
        SQL
      end

      true
    end

  end
end

  # a = ["a", "b", "c"]
  # b = [1, 2, 3]
  # a.zip(b)
  # => [["a", 1], ["b", 2], ["c", 3]]

module BlocRecord
  module Utility
    extend self # extend allows us to add module methods as class methods
    def underscore(camel_cased_word)
      string = camel_cased_word.gsub(/::/, '/')
      string.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      string.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      string.tr!("-", "_")
      string.downcase
    end

    def sql_strings(value)
      # converts String or Numeric input into an appropriately formatted SQL string
      case value
      when String
        "'#{value}'"
      when Numeric
        value.to_s
      else
        "null"
      end
    end

    def convert_keys(options)
      # converts all the keys to string keys. Use either strings or symbols as hash keys.
      options.keys.each {|k| options[k.to_s] = options.delete(k) if k.kind_of?(Symbol)}
      options
      # delete method returns the value of deleted key.
    end

    def instance_variables_to_hash(obj)
      #  Ruby prepends instance variable name strings with @, so we delete that
      Hash[ obj.instance_variables.map{ |var| ["#{var.to_s.delete('@')}",  obj.instance_variable_get(var.to_s)]} ]
      # instance_variable_get returns the value of the given instance variable
    end

    def reload_obj(dirty_obj)
      persisted_obj = dirty_obj.class.find(dirty_obj.id)
      #  takes an object, finds its database record using the find method in the Selection module.
      dirty_obj.instance_variables.each do |instance_variable|
        dirty_obj.instance_variable_set(instance_variable,  persisted_obj.instance_variable_get(instance_variable))
        # overwrites the instance variable values with the stored values from the database.
      end
    end
  end
end

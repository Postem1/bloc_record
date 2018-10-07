require 'bloc_record/utility'
require 'bloc_record/schema'
require 'bloc_record/persistence'
require 'bloc_record/selection'
require 'bloc_record/connection'

module BlocRecord
  class Base
    include Persistence
    extend Selection
    extend Schema
    extend Connection

    def initialize(options={})
      # creates a model of the table
      options = BlocRecord::Utility.convert_keys(options)

      self.class.columns.each do |col|
        self.class.send(:attr_accessor, col) # creates an instance variable getter and setter for each column
        self.instance_variable_set("@#{col}", options[col])
        # set the instance variable to the value corresponding to that key
      end
    end
  end
end

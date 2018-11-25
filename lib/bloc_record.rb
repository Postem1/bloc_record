module BlocRecord
  def self.connect_to(filename, server)
    @database_filename = filename
    @database_server = server
  end

  def self.database_filename
    @database_filename
  end

  def self.database_server
    @database_server
  end
end

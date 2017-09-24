require "./stoertebeker/*"

module Stoertebeker
  # def self.run(*args)
  #   c = RemoteClient.new(*args)
  #   c.start
  #   c
  # end

  class Context
    include DSL

    getter client : RemoteClient

    def initialize(*args)
      @client = RemoteClient.new(*args)
    end

    def run
      @client.start
      with self yield
    end
  end

  # def self.new(*args)
  #   @client = RemoteClient.new(*args)
  #   with self yield
  # end
end

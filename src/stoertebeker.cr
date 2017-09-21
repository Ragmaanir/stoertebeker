require "./stoertebeker/*"

module Stoertebeker
  def self.run(*args)
    c = RemoteClient.new(*args)
    c.start
    c
  end
end

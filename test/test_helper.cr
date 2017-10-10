require "minitest"
require "http/server"

require "../src/stoertebeker"
require "../src/stoertebeker/test_adapters/minitest"

LOGGER = Logger.new(STDOUT)

Stoertebeker.run_minitest(LOGGER) do
  HTTP::Server.new("localhost", 3001, [
    HTTP::ErrorHandler.new,
    HTTP::StaticFileHandler.new("./spec/public", directory_listing: false),
  ])
end

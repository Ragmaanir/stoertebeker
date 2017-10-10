require "microtest"
require "http/server"

require "../src/stoertebeker"
require "../src/stoertebeker/test_adapters/microtest"

include Microtest::DSL

LOGGER = Logger.new(STDOUT)
# LOGGER.level = Logger::DEBUG

Stoertebeker.run_microtest(LOGGER) do
  HTTP::Server.new("localhost", 3001, [
    HTTP::ErrorHandler.new,
    HTTP::StaticFileHandler.new("./spec/public", directory_listing: false),
  ])
end

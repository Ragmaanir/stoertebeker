require "microtest"
require "http/server"

require "../src/stoertebeker"
require "../src/stoertebeker/test_adapters/microtest"

include Microtest::DSL

Log.setup(:info)

Stoertebeker.run_microtest do
  HTTP::Server.new([
    HTTP::ErrorHandler.new,
    HTTP::StaticFileHandler.new("./spec/public", directory_listing: false),
  ])
end

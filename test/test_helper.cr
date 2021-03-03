require "minitest"
require "http/server"

require "../src/stoertebeker"
require "../src/stoertebeker/test_adapters/minitest"

Log.setup(:info)

Stoertebeker.run_minitest do
  HTTP::Server.new([
    HTTP::ErrorHandler.new,
    HTTP::StaticFileHandler.new("./spec/public", directory_listing: false),
  ])
end

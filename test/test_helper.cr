require "minitest"
require "http/server"

require "../src/stoertebeker"

LOGGER = Logger.new(STDOUT)
# LOGGER.level = Logger::DEBUG

CTX = Stoertebeker::Context.new(LOGGER)

success = false

Stoertebeker.run(CTX) do |ctx|
  begin
    ctx.logger.debug("Starting http server")
    server_process = Process.fork do
      HTTP::Server.new("localhost", 3001, [
        HTTP::ErrorHandler.new,
        HTTP::StaticFileHandler.new("./spec/public", directory_listing: false),
      ]).listen
    end
    ctx.logger.debug("Started http server")

    success = Minitest.run(ARGV)
  ensure
    ctx.logger.debug("Stopping http server")
    server_process.try(&.kill) rescue nil
    ctx.logger.debug("Stopped http server")
  end
end

class Test < Minitest::Test
  def ctx
    @ctx ||= CTX
  end
end

exit success ? 0 : -1

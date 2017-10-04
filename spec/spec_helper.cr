require "microtest"
require "http/server"

require "../src/stoertebeker"

include Microtest::DSL

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

    success = Microtest.run([
      Microtest::DescriptionReporter.new,
      Microtest::ErrorListReporter.new,
      Microtest::SlowTestsReporter.new,
      Microtest::SummaryReporter.new,
    ] of Microtest::Reporter)
  ensure
    # make sure the http server is terminated. The electron server and crystal
    # client should be terminated automatically (hopefully, multiple processes are a bitch).
    ctx.logger.debug("Stopping http server")
    server_process.try(&.kill) rescue nil
    ctx.logger.debug("Stopped http server")
  end
end

exit success ? 0 : -1

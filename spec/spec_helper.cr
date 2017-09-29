require "microtest"
require "http/server"

require "../src/stoertebeker"

include Microtest::DSL

LOGGER = Logger.new(STDOUT)
# LOGGER.level = Logger::DEBUG

CTX = Stoertebeker::Context.new(LOGGER)

success = false

Stoertebeker.run(CTX) do
  success = Microtest.run
end

exit success ? 0 : -1

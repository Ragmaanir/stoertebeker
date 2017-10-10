require "./generic"

module Stoertebeker
  macro run_minitest(logger, &server)
    Stoertebeker.run_tests({{logger}}, Minitest::Test, Minitest.run(ARGV)) {{server}}
  end
end

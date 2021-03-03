require "./generic"

module Stoertebeker
  macro run_minitest(&server)
    Stoertebeker.run_tests(Minitest::Test, Minitest.run(ARGV)) {{server}}
  end
end

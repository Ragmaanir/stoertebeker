require "./generic"

module Stoertebeker
  # FIXME use default reporters of microtest
  DEFAULT_MICROTEST_REPORTERS = [
    Microtest::ProgressReporter.new,
    Microtest::ErrorListReporter.new,
    Microtest::SlowTestsReporter.new,
    Microtest::SummaryReporter.new,
  ] of Microtest::Reporter

  macro run_microtest(reporters = Stoertebeker::DEFAULT_MICROTEST_REPORTERS, &server)
    Stoertebeker.run_tests(
      Microtest::Test,
      Microtest.run({{reporters}})
    ) {{server.id}}
  end
end

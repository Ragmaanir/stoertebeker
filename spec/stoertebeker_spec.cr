require "./spec_helper"

describe Stoertebeker do
  test "static html example" do
    CTX.run do |c|
      c.request("localhost:3001/example.html")
      c.wait_for("h1")
      # c.screenshot("./test.png")
    end
  end

  test "another static html example" do
    CTX.run do |c|
      c.request("localhost:3001/example.html")
      c.wait_for("h1")
      # c.screenshot("./another_test.png")
    end
  end
end

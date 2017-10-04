require "./spec_helper"

require "./spec_helper"

describe Stoertebeker do
  FILE_PATH = File.expand_path("./temp/test.png")

  test "readme example" do
    CTX.run do |c|
      c.request("localhost:3001/example.html")
      c.wait_for("h1")
      c.screenshot("../temp/test.png")

      assert File.exists?(FILE_PATH)
      assert File.size(FILE_PATH) > 0
      File.delete(FILE_PATH)
      assert c.current_url == "http://localhost:3001/example.html"
    end
  end
end

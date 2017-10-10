require "./test_helper"

class StoertebekerTest < Minitest::Test
  FILE_PATH = File.expand_path("./temp/test.png")

  def test_static_html_example
    request("http://localhost:3001/example.html")
    wait_for("h1")
    screenshot(FILE_PATH)

    assert File.exists?(FILE_PATH)
    assert File.size(FILE_PATH) > 0
    File.delete(FILE_PATH)
    assert current_url == "http://localhost:3001/example.html"
  end
end

require "./test_helper"

class StoertebekerTest < Test
  FILE_PATH = File.expand_path("./temp/test.png")

  def test_static_html_example
    ctx.run do |c|
      c.request("localhost:3001/example.html")
      c.wait_for("h1")
      c.screenshot(FILE_PATH)

      assert File.exists?(FILE_PATH)
      assert File.size(FILE_PATH) > 0
      File.delete(FILE_PATH)
      assert c.current_url == "http://localhost:3001/example.html"
    end
  end
end

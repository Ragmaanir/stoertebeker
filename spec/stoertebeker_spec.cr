require "./spec_helper"

describe Stoertebeker do
  test "static html example" do
    request("http://localhost:3001/example.html")
    screenshot("./temp/example.png")
    wait_for("h1#example1")
    # p c.evaluate("Array.prototype.slice.call(document.querySelectorAll(\"a\")).map(function(e){ return e.innerHTML })")
    click("a")
    wait_for("h1#example2")
    assert evaluate("Array.prototype.slice.call(document.querySelectorAll(\"h1\")).map(function(e){ return e.innerHTML })") == ["Example 2"]
    screenshot("./temp/example2.png")
  end

  test "another static html example" do
    request("http://localhost:3001/example2.html")
    wait_for("form")
    set_value(".textfield", "somevalue")
    assert evaluate("document.querySelectorAll(\".textfield\")[0].value") == "somevalue"
    assert inner_html("h1") == "Example 2"
  end
end

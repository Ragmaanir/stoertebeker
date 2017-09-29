require "./stoertebeker"

include Stoertebeker

ctx = Stoertebeker::Context.new

ctx.run do |c|
  c.window(width: 1024, height: 768)
  c.request("localhost:3000")
  c.wait_for(".topic_list .topic")
  p c.evaluate("Array.prototype.slice.call(document.querySelectorAll(\".topic_list .topic .title\")).map(function(e){ return e.innerHTML })")
  # screenshot("localhost.png")
  p c.current_url
  p c.page_title
end

ctx.run do |c|
  c.window(width: 1024, height: 768)
  c.request("google.com")
  c.wait_for("form input")
  # screenshot("google.png")
  p c.current_url
  p c.page_title
end

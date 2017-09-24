require "./stoertebeker"

include Stoertebeker

# logger = Logger.new(STDOUT)
# logger.level = Logger::DEBUG

# client = Stoertebeker.new(logger)

# builder = CommandChainBuilder.new(client)
# results = [] of String

# chain = builder
#   .window(width: 1024, height: 768)
#   .goto("localhost:3000")
#   .wait_for(".topic_list .topic")
#   # .screenshot("yyy.png")
#   .evaluate("Array.prototype.slice.call(document.querySelectorAll(\".topic_list .topic .title\")).map(function(e){ return e.innerHTML })") { |result| results << result.to_s }
#   .quit
#   .result
# # FillCommand.new(client, "#search_form_input_homepage", "github nightmare"),
# # ClickCommand.new(client, "#search_button_homepage"),
# # WaitCommand.new(client, "#r1-0 a.result__a"),

# client.start
# client.run_command_chain(chain)

# p results

ctx = Stoertebeker::Context.new

ctx.run do
  window(width: 1024, height: 768)
  request("localhost:3000")
  wait_for(".topic_list .topic")
  evaluate("Array.prototype.slice.call(document.querySelectorAll(\".topic_list .topic .title\")).map(function(e){ return e.innerHTML })") { |result| p result }
  screenshot("localhost.png")
end

ctx.run do
  window(width: 1024, height: 768)
  request("google.com")
  # wait_for("form input")
  screenshot("google.png")
end

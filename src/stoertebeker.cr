require "./stoertebeker/*"

module Stoertebeker
  # TODO Put your code here
end

# class Message
#   getter type : String
#   getter data : JSON::Any?

#   def self.command(type : String, data : Hash(String, JSON::Type) = {} of String => JSON::Type)
#     json_hash = data.merge({"command" => type})
#     json_hash = json_hash.map { |k, v| {k, v}.as(Tuple(String, JSON::Type)) }.to_h

#     new("command", JSON::Any.new(json_hash))
#   end

#   def initialize(@type, @data = nil)
#   end

#   abstract def to_json(b : JSON::Builder)
# end

# chain = Stoertebeker::CommandChainBuilder.new

# chain
#   .goto("https://duckduckgo.com")
#   .fill("#search_form_input_homepage", "github nightmare")
#   .click("#search_button_homepage")
#   .wait("#r1-0 a.result__a")
#   .result

# .evaluate { document.querySelector("#r1-0 a.result__a").href }
# .end
# .then(console.log)
# .catch { |error|
#   console.error("Search failed:", error)
# }

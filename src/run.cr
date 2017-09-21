require "./stoertebeker"

include Stoertebeker

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

client = Stoertebeker.run(logger)

builder = CommandChainBuilder.new(client)

chain = CommandChain.new(client, [
  GotoCommand.new(client, "localhost:3000"),
  ScreenshotCommand.new(client, "yyy.png"),
  # QuitCommand.new(client)
  # FillCommand.new(client, "#search_form_input_homepage", "github nightmare"),
  # ClickCommand.new(client, "#search_button_homepage"),
  # WaitCommand.new(client, "#r1-0 a.result__a"),
] of Command)

client.run_command_chain(chain)

Fiber.yield

# include Stoertebeker::ServerResponses

# spawn do
#   client.socket.connect(client.server_address)

#   client.send(ClientMessages::GotoCommandMessage.new(URI.parse("http://localhost:3000")))

#   loop do
#     logger.info "Receiving"
#     msg, _ = client.socket.receive(512)
#     p msg
#     msg = msg.split("\f").first # FIXME partial messages?
#     msg = Response.parse(msg)
#     client.channel.send(msg)
#   end
# end

# spawn do
#   # loop do
#   #   puts "Receiving on channel"
#   #   msg = client.channel.receive
#   #   logger.debug "RECEIVED: #{msg}"
#   # end
#   logger.info "spawned"
#   chain.commands.each do |cmd|
#     puts cmd.class
#     cmd.call
#     # msg = client.channel.receive
#     # logger.debug "RECEIVED: #{msg}"
#   end
# end

# Fiber.yield # FIXME required?

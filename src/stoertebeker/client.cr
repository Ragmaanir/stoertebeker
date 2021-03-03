require "socket"

require "./client_messages"
require "./server_responses"

module Stoertebeker
  # LOG_FORMATTER = Logger::Formatter.new do |severity, datetime, progname, message, io|
  #   io << datetime.to_s("%Y-%m-%d %H:%M:%S : ")
  #   io << message
  # end

  abstract class Client
    include ClientMessages
    include ServerResponses

    abstract def channel : Channel(Response)
    abstract def start
    abstract def send(msg : Message)
  end

  class RemoteClient < Client
    getter server_address : Socket::UNIXAddress
    getter socket : Socket
    getter channel : Channel(Response)

    def initialize(@server_address)
      # logger.formatter = LOG_FORMATTER
      @socket = Socket.unix(blocking: true)
      @channel = Channel(Response).new

      socket.read_timeout = 1.second
      socket.write_timeout = 1.second
      socket.keepalive = true
    end

    def start
      Stoertebeker.wait_for("Failed to connect to socket: #{server_address.path}") do
        File.exists?(server_address.path)
      end

      socket.connect(server_address)
    end

    def receive_response
      msg, _ = socket.receive(2048)
      msg = msg.split("\f").first # FIXME partial messages?
      Response.parse(msg)
    end

    def send(msg : Message)
      Log.debug { "SENDING: #{msg.to_json}" }
      socket.send(msg.to_json + "\f")
    end
  end # Client

  # class MockClient < Client
  #   getter sent : Array(Message)

  #   def initialize(@logger = Logger.new(STDOUT))
  #     @channel = Channel(Message).new
  #   end

  #   def start
  #     # spawn_receiver
  #     spawn_message_processor

  #     Fiber.yield
  #   end

  #   def send(msg : Message)
  #     logger.debug "SENDING: #{msg.to_json}"
  #     socket.send(msg.to_json + "\f")
  #   end

  #   # def spawn_receiver
  #   #   spawn do
  #   #     loop do
  #   #       logger.info "Receiving"
  #   #       msg, add = socket.receive
  #   #       msg = msg.split("\f").first
  #   #       msg = Message.from_json(msg)
  #   #       channel.send(msg)
  #   #     end
  #   #   end
  #   # end

  #   def spawn_message_processor
  #     spawn do
  #       loop do
  #         msg = channel.receive

  #         logger.debug "RECEIVED: #{msg.to_json}"

  #         case msg.type
  #         when "ready"
  #           filename = File.join(Dir.current, "xxx.png")
  #           send(Message.command("screenshot", {"filename" => filename}))
  #         when "screenshot.done"
  #           send(Message.command("quit"))
  #           s.close
  #           logger.info "Exiting"
  #           exit
  #         end
  #       end
  #     end
  #   end
  # end
end

require "logger"
require "socket"

require "./messages"

module Stoertebeker
  abstract class Client
    include Messages

    abstract def logger : Logger
    abstract def channel : Channel(Message)
    abstract def start
    abstract def send(msg : Message)
  end

  class RemoteClient < Client
    getter server_address : Socket::UNIXAddress
    getter socket : Socket
    getter logger : Logger
    getter channel : Channel(Message)

    def initialize(@logger = Logger.new(STDOUT), @server_address = Socket::UNIXAddress.new("/tmp/app.stoertebeker"))
      @socket = Socket.unix(blocking: true)
      @channel = Channel(Message).new
    end

    def start
      spawn_receiver
      spawn_message_processor

      Fiber.yield
    end

    def send(msg : Message)
      logger.debug "SENDING: #{msg.to_json}"
      socket.send(msg.to_json + "\f")
    end

    def spawn_receiver
      spawn do
        socket.connect(server)

        loop do
          logger.info "Receiving from socket"
          msg, add = socket.receive
          msg = msg.split("\f").first
          msg = Message.from_json(msg)
          channel.send(msg)
        end
      end
    end

    def spawn_message_processor
      spawn do
        loop do
          msg = channel.receive

          logger.debug "RECEIVED: #{msg.to_json}"

          case msg.type
          when "ready"
            filename = File.join(Dir.current, "xxx.png")
            send(Message.command("screenshot", {"filename" => filename}))
          when "screenshot.done"
            send(Message.command("quit"))
            s.close
            logger.info "Exiting"
            exit
          end
        end
      end
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

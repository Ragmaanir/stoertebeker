require "logger"
require "socket"

require "./client_messages"
require "./server_responses"

module Stoertebeker
  LOG_FORMATTER = Logger::Formatter.new do |severity, datetime, progname, message, io|
    io << datetime.to_s("%Y-%m-%d %H:%M:%S : ")
    io << message
  end

  abstract class Client
    include ClientMessages
    include ServerResponses

    abstract def logger : Logger
    abstract def channel : Channel(Message)
    abstract def start
    abstract def send(msg : Message)
  end

  class RemoteClient < Client
    getter server_address : Socket::UNIXAddress
    getter socket : Socket
    getter logger : Logger
    getter channel : Channel(Response)

    def initialize(@logger = Logger.new(STDOUT), @server_address = Socket::UNIXAddress.new("/tmp/app.stoertebeker"))
      logger.formatter = LOG_FORMATTER
      @socket = Socket.unix(blocking: true)
      @channel = Channel(Response).new

      socket.read_timeout = 1.second
      socket.write_timeout = 1.second
      socket.keepalive = true
    end

    def start
      socket.connect(server_address)
      # spawn_response_receiver
      # spawn_message_processor

      # Fiber.yield
    end

    # def spawn_response_receiver
    #   spawn do
    #     socket.connect(server_address)

    #     loop do
    #       logger.info "Receiving"
    #       msg, _ = socket.receive(512)
    #       puts "received"
    #       p msg
    #       msg = msg.split("\f").first # FIXME partial messages?
    #       msg = Response.parse(msg)
    #       channel.send(msg)
    #     end
    #   end
    # end

    # def run_command_chain(chain : CommandChain)
    #   logger.info("EXECUTING CHAIN")

    #   spawn do
    #     socket.connect(server_address)

    #     Fiber.yield # send messages before receiving

    #     loop do
    #       logger.info "Receiving"
    #       msg, _ = socket.receive(512)
    #       logger.info "PACKET: #{msg}"
    #       msg = msg.split("\f").first # FIXME partial messages?
    #       msg = Response.parse(msg)
    #       channel.send(msg)
    #     end
    #   end

    #   spawn do
    #     chain.commands.each do |cmd|
    #       logger.info cmd.class
    #       cmd.call
    #     end
    #   end

    #   Fiber.yield # FIXME required?
    #   logger.info "EXITING"
    # end

    def run_command_chain(chain : CommandChain)
      raise "Socket is closed" if socket.closed?
      chain.commands.each do |cmd|
        logger.info cmd.class
        cmd.call
      end
    end

    def receive_response
      msg, _ = socket.receive(2048)
      logger.info "PACKET: #{msg}"
      msg = msg.split("\f").first # FIXME partial messages?
      msg = Response.parse(msg)
    end

    # def receive_response
    #   # channel.wait_for_receive
    #   # a = channel.receive_select_action
    #   # channel.receive
    #   # a.execute
    #   channel.receive
    # end

    def send(msg : Message)
      logger.debug "SENDING: #{msg.to_json}"
      socket.send(msg.to_json + "\f")
    end

    # def spawn_message_processor
    #   spawn do
    #     loop do
    #       msg = channel.receive

    #       logger.debug "RECEIVED: #{msg.to_json}"

    #       # case msg.type
    #       # when "ready"
    #       #   filename = File.join(Dir.current, "xxx.png")
    #       #   send(Message.command("screenshot", {"filename" => filename}))
    #       # when "screenshot.done"
    #       #   send(Message.command("quit"))
    #       #   s.close
    #       #   logger.info "Exiting"
    #       #   exit
    #       # end
    #     end
    #   end
    # end
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

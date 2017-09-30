require "./stoertebeker/*"

module Stoertebeker
  SOCKET_FILE = "/tmp/app.stoertebeker"

  def self.wait_for(msg = "Timeout", tries = 5, &block : -> Bool)
    while (tries -= 1) >= 0
      return if block.call
      sleep 1
    end

    raise msg
  end

  class Context
    include DSL

    getter client : RemoteClient
    getter logger : Logger
    @server_process : Process?

    def initialize(@logger : Logger = Logger.new(STDOUT), *args)
      @client = RemoteClient.new(logger, *args)
    end

    def start_client
      logger.debug("Starting client")
      @client.start
      ping
      logger.debug("Pinged client")
    end

    def start_server
      logger.debug("Starting electron server")
      # @server_process = Process.new(
      #   "./bin/server",
      #   input: false,
      #   output: false,
      #   error: false,
      #   chdir: File.join(Dir.current, "tmp/")
      # )
      @server_process = Process.new("./bin/server")
      Stoertebeker.wait_for("Timeout looking for socket") { File.exists?(SOCKET_FILE) }
      logger.debug("Started electron server")
    end

    def server_process
      @server_process.not_nil!
    end

    def stop_server
      logger.debug("Stopping electron server")
      quit
      # server_process.wait
      server_process.kill
      logger.debug("Stopped electron server")
    end

    def run
      yield(self)
    end
  end

  def self.run(ctx : Stoertebeker::Context = Stoertebeker::Context.new)
    File.delete(SOCKET_FILE) if File.exists?(SOCKET_FILE)

    server_proc = nil

    begin
      ctx.start_server
      ctx.start_client

      yield ctx
    rescue e
      p e
      raise e
    ensure
      ctx.ping
      ctx.stop_server rescue nil
      ctx.logger.debug("Stopping http server")
      server_proc.try(&.kill) rescue nil
      ctx.logger.debug("Stopped http server")
    end
  end
end

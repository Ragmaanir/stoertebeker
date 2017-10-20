require "./stoertebeker/*"

module Stoertebeker
  SOCKET_DIR  = File.expand_path("./temp/")
  SOCKET_FILE = File.join(SOCKET_DIR, "/app.stoertebeker")
  ROOT_PATH   = File.real_path(File.join(File.dirname(__FILE__), ".."))

  # Waits for the block *tries* times to return true, waiting *delay* ms after each try.
  def self.wait_for(msg = "wait_for timed out", tries = 5, delay = 1000, &block : -> Bool)
    while (tries -= 1) >= 0
      return if block.call
      sleep Time::Span.new(0, 0, 0, 0, delay) # milliseconds
    end

    raise msg
  end

  # Starts and terminates the electron server and connects the crystal client to it.
  # Commands can be executed against the server vie IPC from this context, using the DSL methods.
  class Context
    include DSL

    getter? debugging : Bool = ENV["STOERTEBEKER_DEBUG"]? == "true"
    getter client : RemoteClient
    getter logger : Logger
    getter! server_process : Process?

    def initialize(@logger : Logger = Logger.new(STDOUT), server_address = Socket::UNIXAddress.new(SOCKET_FILE), *args)
      @client = RemoteClient.new(logger, server_address, *args)
    end

    # Connects the client to the electron socket and pings the server.
    def start_client
      logger.debug("Starting client")
      @client.start
      ping
      logger.debug("Pinged client")
    end

    # Starts the electron server. It first runs npm install and raises if it fails.
    # Waits for the socket file to be created.
    def start_server
      Dir.cd(ROOT_PATH) do
        logger.debug("Starting electron server")
        # @server_process = Process.new(
        #   "./bin/server",
        #   input: false,
        #   output: false,
        #   error: false,
        #   chdir: File.join(Dir.current, "tmp/")
        # )
        err = IO::Memory.new
        dir = File.join(ROOT_PATH, "browser")

        status = Process.run("npm", ["install"], error: err, output: debugging?, chdir: dir)

        if !status.success?
          puts err
          raise "npm install failed"
        end

        @server_process = Process.new(
          "./bin/server",
          env: {"SOCKET_DIR" => SOCKET_DIR},
          output: debugging?,
          error: debugging?
        )
        Stoertebeker.wait_for("Timeout looking for socket", tries: 10, delay: 500) {
          p SOCKET_DIR
          puts `ls #{SOCKET_DIR}`
          File.exists?(client.server_address.path)
        }
        logger.debug("Started electron server")
      end
    end

    # Stops the server by firs sending the quit-command and then killing the process.
    def stop_server
      logger.debug("Stopping electron server")
      quit rescue nil
      # server_process.wait
      sleep 1
      server_process.kill rescue nil
      logger.debug("Stopped electron server")
    end
  end

  # Starts the electron server and client, yields the block with the `Context` and
  # terminates the electron server after the block finishes.
  def self.run(ctx : Stoertebeker::Context = Stoertebeker::Context.new)
    File.delete(SOCKET_FILE) if File.exists?(SOCKET_FILE)

    begin
      ctx.start_server
      ctx.start_client

      yield ctx
    rescue e
      p e
      raise e
    ensure
      # ctx.ping
      ctx.stop_server rescue nil
    end
  end
end

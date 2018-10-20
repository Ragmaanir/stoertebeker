module Stoertebeker
  macro run_tests(logger, test_context, test_runner, &server)
    {% raise("Logger needs to be a constant #{logger.id}") unless logger.class_name == "Path" && logger.resolve %}
    STOERTEBEKER_CONTEXT = Stoertebeker::Context.new({{logger}})

    success = false

    class {{test_context}}
      def stoertebeker_context
        STOERTEBEKER_CONTEXT
      end

      delegate window, request, screenshot, wait_for, inner_html, click, set_value, evaluate, current_url, to: stoertebeker_context
    end

    Stoertebeker.run(STOERTEBEKER_CONTEXT) do |ctx|
      begin
        ctx.logger.debug("Starting http server")

        host = "localhost"
        port = 3001

        http_server = begin
          {{server.body}}
        end

        server_process = Process.fork do
          http_server.bind_tcp(host, port)
          http_server.listen
        end

        scheme = "http"

        Stoertebeker.wait_for do
          begin
            url = "#{scheme}://#{host}:#{port}/"
            HTTP::Client.get(url).status_code != nil
          rescue e : Errno
            false
          end
        end

        ctx.logger.debug("Started http server")

        success = {{test_runner}}
      ensure
        # make sure the http server is terminated. The electron server and crystal
        # client should be terminated automatically (hopefully, multiple processes are a bitch).
        ctx.logger.debug("Stopping http server")
        server_process.try(&.kill) rescue nil
        ctx.logger.debug("Stopped http server")
      end
    end

    exit success ? 0 : -1
  end
end

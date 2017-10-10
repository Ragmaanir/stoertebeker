module Stoertebeker
  macro run_tests(logger, test_context, test_runner, &server)
    {% raise("Logger needs to be a constant #{logger.id}") unless logger.class_name == "Path" && logger.resolve %}
    STOERTEBEKER_CONTEXT = Stoertebeker::Context.new({{logger}})

    success = false

    class {{test_context}}
      def stoertebeker_context
        STOERTEBEKER_CONTEXT
      end

      delegate request, screenshot, wait_for, click, evaluate, current_url, to: stoertebeker_context
    end

    Stoertebeker.run(STOERTEBEKER_CONTEXT) do |ctx|
      begin
        ctx.logger.debug("Starting http server")

        http_server = {{server.body}}

        server_process = Process.fork do
          http_server.listen
        end

        scheme = {% if flag?(:without_openssl) %}
          "http"
        {% else %}
          http_server.tls ? "https" : "http"
        {% end %}

        Stoertebeker.wait_for do
          begin
            url = "#{scheme}://#{http_server.host}:#{http_server.port}/"
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

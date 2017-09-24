require "./client_messages"

module Stoertebeker
  module Commands
    abstract class Command
      include ClientMessages

      getter client : Client

      def initialize(@client)
      end

      def send_message(msg : Message)
        client.send(msg)
      end

      def receive_response
        r = client.receive_response
        logger.info "RESPONSE: #{r}"
        r
      end

      def receive_confirmation_response(name : String)
        r = client.receive_response
        logger.info "RESPONSE: #{r}"
        raise "Unexpected Response: #{r.type} != #{name}" unless r.type == name
        r
      end

      private def logger
        client.logger
      end

      def call
        logger.info "BEGIN COMMAND: #{self.class.name}"
        call_impl
        logger.info "END COMMAND: #{self.class.name}"
      end

      private abstract def call_impl
    end

    class WindowCommand < Command
      getter width : Int32
      getter height : Int32

      def initialize(client, @width, @height)
        super(client)
      end

      def call_impl
        send_message(WindowCommandMessage.new(width, height))
        receive_confirmation_response("window")
      end

      def_equals_and_hash client, uri
    end

    class GotoCommand < Command
      getter uri : URI

      def initialize(client, uri : String)
        initialize(client, URI.parse(uri))
      end

      def initialize(client, @uri)
        super(client)
      end

      # def call_impl
      #   send_message(GotoCommandMessage.new(uri))
      #   msg = receive_confirmation_response("status")

      #   status = msg.data["status"].as_i

      #   if status != 200
      #     url = msg.data["url"].as_s
      #     desc = msg.data["message"]
      #     raise "URL: #{url}, origURL: #{msg.data["originalURL"]?}, Status: #{status}, Msg: #{desc}"
      #   end
      #   receive_confirmation_response("ready")
      # end

      def call_impl
        send_message(GotoCommandMessage.new(uri))

        ready = false
        completed = false

        loop do
          msg = receive_response

          case msg.type
          when "completed" then completed = true
          when "ready"     then ready = true
          end

          break if completed && ready
        end
      end

      def_equals_and_hash client, uri
    end

    class ScreenshotCommand < Command
      getter filename : String

      def initialize(client, @filename)
        super(client)
      end

      def call_impl
        send_message(ScreenshotCommandMessage.new(filename))

        receive_confirmation_response("screenshot")
      end

      def_equals_and_hash client, filename
    end

    class FillCommand < Command
      getter selector : String
      getter value : String

      def initialize(client, @selector, @value)
        super(client)
      end

      def call_impl
        send_message(FillCommandMessage.new(selector, value))
      end

      def_equals_and_hash client, selector, value
    end

    class ClickCommand < Command
      getter selector : String

      def initialize(client, @selector)
        super(client)
      end

      def call_impl
        send_message(ClickCommandMessage.new(selector))
      end

      def_equals_and_hash client, selector
    end

    class WaitCommand < Command
      getter selector : String

      def initialize(client, @selector)
        super(client)
      end

      def call_impl
        send_message(WaitCommandMessage.new(selector))

        receive_confirmation_response("wait_success")
      end

      def_equals_and_hash client, selector
    end

    class EvaluateCommand < Command
      getter script : String
      getter callback : ((JSON::Any) ->) | Nil

      def initialize(client, @script, @callback = nil)
        super(client)
      end

      def call_impl
        send_message(EvaluateCommandMessage.new(script))

        r = receive_confirmation_response("evaluate")

        if c = callback
          c.call(r.data)
        end
      end

      def_equals_and_hash client, selector
    end

    class QuitCommand < Command
      def call_impl
        send_message(QuitCommandMessage.new)
      end

      def_equals_and_hash client
    end
  end # Commands
end

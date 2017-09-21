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

      private def logger
        client.logger
      end
    end

    class GotoCommand < Command
      getter uri : URI

      def initialize(client, uri : String)
        initialize(client, URI.parse(uri))
      end

      def initialize(client, @uri)
        super(client)
      end

      def call
        logger.info "BEGIN COMMAND: #{self.class.name}"

        send_message(GotoCommandMessage.new(uri))
        response = receive_response

        logger.info "END COMMAND: #{self.class.name}"
      end

      def_equals_and_hash client, uri
    end

    class ScreenshotCommand < Command
      getter filename : String

      def initialize(client, @filename)
        super(client)
      end

      def call
        logger.info "BEGIN COMMAND: #{self.class.name}"
        send_message(ScreenshotCommandMessage.new(filename))

        response = receive_response

        logger.info "END COMMAND: #{self.class.name}"
      end

      def_equals_and_hash client, filename
    end

    class FillCommand < Command
      getter selector : String
      getter value : String

      def initialize(client, @selector, @value)
        super(client)
      end

      def call
        send_message(FillCommandMessage.new(selector, value))
      end

      def_equals_and_hash client, selector, value
    end

    class ClickCommand < Command
      getter selector : String

      def initialize(client, @selector)
        super(client)
      end

      def call
        send_message(ClickCommandMessage.new(selector))
      end

      def_equals_and_hash client, selector
    end

    class WaitCommand < Command
      getter selector : String

      def initialize(client, @selector)
        super(client)
      end

      def call
        send_message(WaitCommandMessage.new(selector))
      end

      def_equals_and_hash client, selector
    end

    class QuitCommand < Command
      def call
        logger.info "BEGIN COMMAND: #{self.class.name}"
        send_message(QuitCommandMessage.new)
        logger.info "END COMMAND: #{self.class.name}"
      end

      def_equals_and_hash client
    end
  end # Commands
end

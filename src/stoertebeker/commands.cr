require "./messages"

module Stoertebeker
  module Commands
    abstract class Command
      include Messages

      getter client : Client

      def initialize(@client)
      end

      def send_message(msg : Message)
        logger.debug "SENDING: #{msg.to_json}"
        client.send(msg)
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
        send_message(GotoCommandMessage.new(uri))
      end

      def_equals_and_hash client, uri
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
  end # Commands
end

require "json"
require "uri"

module Stoertebeker
  module ClientMessages
    abstract class Message
      abstract def type : String

      abstract def to_json(b : JSON::Builder)

      def to_json
        io = IO::Memory.new
        b = JSON::Builder.new(io)
        b.document do
          to_json(b)
        end
        io.to_s
      end
    end

    abstract class CommandMessage < Message
      def type
        "command"
      end

      def to_json(b : JSON::Builder)
        b.object do
          b.field "type", type
          b.field "data" do
            cmd_json(b)
          end
        end
      end

      private abstract def cmd_json(b : JSON::Builder)
    end

    class GotoCommandMessage < CommandMessage
      getter uri : URI

      def initialize(@uri)
      end

      def cmd_json(b : JSON::Builder)
        b.object do
          b.field "type", "goto"
          b.field "url", uri.to_s
        end
      end
    end

    class ScreenshotCommandMessage < CommandMessage
      getter filename : String

      def initialize(@filename)
      end

      def cmd_json(b : JSON::Builder)
        b.object do
          b.field "type", "screenshot"
          b.field "filename", filename
        end
      end
    end

    class FillCommandMessage < CommandMessage
      getter selector : String
      getter value : String

      def initialize(@selector, @value)
      end

      def cmd_json(b : JSON::Builder)
        b.object do
          b.field "type", "fill"
          b.field "selector", selector
          b.field "value", value
        end
      end
    end

    class ClickCommandMessage < CommandMessage
      getter selector : String

      def initialize(@selector)
      end

      def cmd_json(b : JSON::Builder)
        b.object do
          b.field "type", "click"
          b.field "selector", selector
        end
      end
    end

    class WaitCommandMessage < CommandMessage
      getter selector : String

      def initialize(@selector)
      end

      def cmd_json(b : JSON::Builder)
        b.object do
          b.field "type", "wait"
          b.field "selector", selector
        end
      end
    end

    class QuitCommandMessage < CommandMessage
      def cmd_json(b : JSON::Builder)
        b.object do
          b.field "type", "quit"
        end
      end
    end
  end # Messages
end

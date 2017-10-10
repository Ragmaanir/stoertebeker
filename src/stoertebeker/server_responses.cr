require "json"

module Stoertebeker
  module ServerResponses
    class Response
      def self.parse(raw : String)
        hash = JSON.parse(raw)
        new(hash)
      end

      getter json : JSON::Any

      def initialize(@json)
      end

      def type
        json["type"].as_s
      end

      def data
        json["data"]
      end

      def to_s(io : IO)
        io << "Response(#{type}, #{data})"
      end
    end
  end # ServerResponses
end

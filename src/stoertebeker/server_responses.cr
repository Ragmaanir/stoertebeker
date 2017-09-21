require "json"

module Stoertebeker
  module ServerResponses
    class Response
      getter type : String

      def self.parse(raw : String)
        hash = JSON.parse(raw)
        # t = hash["type"].as_s
        # case t
        # when "command"
        #   CommandResponse.new(hash)
        # else raise "invalid response message type: #{t}"
        # end
        new(hash["type"].as_s)
      end

      def initialize(@type)
      end
    end

    # class CommandResponse < Response
    #   getter type : String
    #   getter data : Hash(String, JSON::Type)

    #   def initialize(json : JSON::Any)
    #     @type = json["type"].as_s
    #     @data = json["data"].as_h
    #   end
    # end

    # class CommandResponse
    #   class Cmd
    #     JSON.mapping(
    #       type: String,
    #       data?: JSON::Any
    #     )
    #   end

    #   JSON.mapping(
    #     type: String,
    #     command: {type: Cmd, nilable: true}
    #   )
    # end
  end
end

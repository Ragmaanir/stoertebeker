require "json"
require "socket"

struct Message
  JSON.mapping(
    type: String,
    data: {type: JSON::Any, nilable: true}
  )

  getter type : String
  getter data : JSON::Any?

  def initialize(@type, @data = nil)
  end

  # def to_json
  #   #{type: type, data: data}.to_json
  #   JSON.build do |b|
  #     b.field "type", type
  #     b.
  #   end
  # end
end

server = Socket::UNIXAddress.new("/tmp/app.stoertebeker")
s = Socket.unix(blocking: true).as(Socket)

send_message = ->(msg : String) {
  puts "SENDING: #{msg}"
  s.send(msg + "\f")
}

channel = Channel(Message).new

spawn do
  begin
    s.connect(server)

    send_message.call({type: "command", data: {type: "goto", url: "localhost:3000"}}.to_json)

    loop do
      puts "Receiving from socket"
      msg, add = s.receive(512)
      msg = msg.split("\f").first
      msg = Message.from_json(msg)
      p msg
      channel.send(msg)
    end
  rescue e
    p e
    raise e
  end
end

spawn do
  begin
    loop do
      puts "Reading from channel"

      msg = channel.receive

      puts "RECEIVED: #{msg.to_json}"

      case msg.type
      when "ready"
        send_message.call({type: "command", data: {type: "screenshot", filename: "xxx.png"}}.to_json)
      when "screenshot"
        send_message.call({type: "command", data: {type: "quit"}}.to_json)
        s.close
        puts "Exiting"
        exit
      end
    end
  rescue e
    p e
    raise e
  end
end

Fiber.yield

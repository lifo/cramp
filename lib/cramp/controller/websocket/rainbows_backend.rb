require 'rainbows'

class Rainbows::EventMachine::Client
  include Cramp::Controller::WebsocketExtension

  def websocket_handshake!
    @state = :websocket
  end

  def receive_data_with_websocket(data)
    case @state
    when :websocket
      callback = @env[WEBSOCKET_RECEIVE_CALLBACK]
      callback.call(data) if callback
    else
      receive_data_without_websocket(data)
    end
  end

  alias_method_chain :receive_data, :websocket
end

class Rainbows::HttpResponse
  class << self

    def write_with_magic(socket, rack_response, out = [])
      if socket.websocket?
        socket.write socket.websocket_upgrade_data
        socket.websocket_handshake!

        out = nil # To make sure Rainbows! doesn't send back regular HTTP headers
      end

      write_without_magic(socket, rack_response, out)
    end

    alias_method_chain :write, :magic
  end

end

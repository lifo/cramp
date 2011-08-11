require 'thin'

silence_warnings { Thin::Server::DEFAULT_TIMEOUT = 0 }

class Thin::Connection
  # Called when data is received from the client.
  def receive_data(data)
    trace { data }

    case @serving
    when :websocket
      callback = @request.env[Thin::Request::WEBSOCKET_RECEIVE_CALLBACK]
      callback.call(data) if callback
    else
      if @request.parse(data)
        if @request.websocket?
          @response.persistent!
          @response.websocket_upgrade_data = @request.websocket_upgrade_data
          @serving = :websocket
        end

        process
      end
    end
  rescue Thin::InvalidRequest => e
    log "!! Invalid request"
    log_error e
    close_connection
  end
end

class Thin::Request
  include Cramp::WebsocketExtension

  def websocket_upgrade_data
    protocol_class.new(@env, websocket_url, body.read).handshake
  end

end

class Thin::Response
  # Headers for sending Websocket upgrade
  attr_accessor :websocket_upgrade_data

  def each
    websocket_upgrade_data ? yield(websocket_upgrade_data) : yield(head)
    if @body.is_a?(String)
      yield @body
    else
      @body.each { |chunk| yield chunk }
    end
  end
end

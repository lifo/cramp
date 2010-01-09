require 'thin'

class Thin::Connection
  WEBSOCKET_RECEIVE_CALLBACK = 'websocket.receive_callback'.freeze

  # Called when data is received from the client.
  def receive_data(data)
    trace { data }

    case @serving
    when :websocket
      callback = @request.env[WEBSOCKET_RECEIVE_CALLBACK]
      callback.call(data) if callback
    else
      if @request.parse(data)
        if @request.websocket?
          @response.websocket_upgrade_data = @request.websocket_upgrade_data
          @serving = :websocket
        end

        process
      end
    end
  rescue InvalidRequest => e
    log "!! Invalid request"
    log_error e
    close_connection
  end
end

class Thin::Request
  def websocket?
    @env['HTTP_CONNECTION'] == 'Upgrade' && @env['HTTP_UPGRADE'] == 'WebSocket'
  end

  # upgrade headers for websocket connections
  def websocket_upgrade_data
    location  = "ws://#{@env['HTTP_HOST']}#{@env['REQUEST_PATH']}"

    upgrade =  "HTTP/1.1 101 Web Socket Protocol Handshake\r\n"
    upgrade << "Upgrade: WebSocket\r\n"
    upgrade << "Connection: Upgrade\r\n"
    upgrade << "WebSocket-Origin: #{@env['HTTP_ORIGIN']}\r\n"
    upgrade << "WebSocket-Location: #{location}\r\n\r\n"

    upgrade
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

class Cramp::Websocket::Rainbows < Rainbows::EventMachine::Client
  include Cramp::WebsocketExtension

  def receive_data(data)
    case @state
    when :websocket
      callback = @env[WEBSOCKET_RECEIVE_CALLBACK]
      callback.call(data) if callback
    else
      super
    end
  end

  def on_read(data)
    if @state == :headers
      @hp.add_parse(data) or return want_more
      @state = :body
      if 0 == @hp.content_length && !websocket?
        app_call NULL_IO # common case
      else # nil or len > 0
        prepare_request_body
      end
    elsif @state == :body && websocket? && @hp.body_eof?
      @state = :websocket
      @input.rewind

      write(protocol_class.new(@env, websocket_url, @buf).handshake)
      app_call NULL_IO
    else
      super
    end
  rescue => e
    handle_error(e)
  end

  def write_response(status, headers, body, alive)
    write_headers(status, headers, alive) unless websocket?
    write_body_each(body)
  ensure
    body.close if body.respond_to?(:close)
  end
end

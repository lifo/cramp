require 'rainbows'

class Rainbows::EventMachine::Client
  include Cramp::WebsocketExtension

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

  def on_read_with_websocket(data)
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

      handler = @env['HTTP_SEC_WEBSOCKET_KEY1'] && @env['HTTP_SEC_WEBSOCKET_KEY2'] ? Protocol76 : Protocol75
      write(handler.new(@env, websocket_url, @buf).handshake)
      app_call NULL_IO
    else
      on_read_without_websocket(data)
    end
  rescue => e
    handle_error(e)
  end

  alias_method_chain :on_read, :websocket

  def write_response_with_websocket(status, headers, body, alive)
    write_headers(status, headers, alive) unless websocket?
    write_body_each(body)
  ensure
    body.close if body.respond_to?(:close)
  end

  alias_method_chain :write_response, :websocket
end

module Cramp
  class Action < Abstract
    include PeriodicTimer
    include KeepConnectionAlive

    def initialize(env)
      super
      
      case
      when Faye::EventSource.eventsource?(env)
        # request has Accept: text/event-stream
        # faye server adapter intercepts headers - need to send them in send_initial_response or use faye's implementation
        @eventsource_detected = true
        unless transport == :sse
          err = "WARNING: Cramp got request with EventSource header on action with transport #{transport} (not sse)! Response may not contain valid http headers!"
          Cramp.logger ? Cramp.logger.error(err) : $stderr.puts(err)
        end
      when Faye::WebSocket.websocket?(env)
        @web_socket = Faye::WebSocket.new(env)
        @web_socket.onmessage = lambda do |event|
          message = event.data
          _invoke_data_callbacks(message) if message.is_a?(String)
        end
      end
    end

    protected

    def render(body, *args)
      send(:"render_#{transport}", body, *args)
    end

    def send_initial_response(status, headers, body)
      case transport
      when :long_polling
        # Dont send no initial response. Just cache it for later.
        @_lp_status = status
        @_lp_headers = headers
      when :sse
        super
        if @eventsource_detected
          # Reconstruct headers that were killed by faye server adapter:
          @body.call("HTTP/1.1 200 OK\r\n#{headers.map{|(k,v)| "#{k}: #{v.is_a?(Time) ? v.httpdate : v.to_s}"}.join("\r\n")}\r\n\r\n")
        end
        # send retry? @body.call("retry: #{ (@retry * 1000).floor }\r\n\r\n")
      else
        super
      end
    end

    class_attribute :default_sse_headers
    self.default_sse_headers = {'Content-Type' => 'text/event-stream', 'Cache-Control' => 'no-cache, no-store', 'Connection' => 'keep-alive'}

    class_attribute :default_chunked_headers
    self.default_chunked_headers = {'Transfer-Encoding' => 'chunked', 'Connection' => 'keep-alive'}

    def build_headers
      case transport
      when :sse
        status, headers = respond_to?(:respond_with, true) ? respond_with : [200, {'Content-Type' => 'text/html'}]
        [status, headers.merge(self.default_sse_headers)]
      when :chunked
        status, headers = respond_to?(:respond_with, true) ? respond_with : [200, {}]

        headers = headers.merge(self.default_chunked_headers)
        headers['Content-Type'] ||= 'text/html'
        headers['Cache-Control'] ||= 'no-cache'

        [status, headers]
      else
        super
      end
    end

    def render_regular(body, *)
      @body.call(body)
    end

    def render_long_polling(data, *)
      @_lp_headers['Content-Length'] = data.size.to_s

      send_response(@_lp_status, @_lp_headers, @body)
      @body.call(data)

      finish
    end

    def render_sse(data, options = {})
      #TODO: Faye uses \r\n for newlines, some compatibility?
      result = "id: #{sse_event_id}\n"
      result << "event: #{options[:event]}\n" if options[:event]
      result << "retry: #{options[:retry]}\n" if options[:retry]

      data.split(/\n/).each {|d| result << "data: #{d}\n" }
      result << "\n"

      @body.call(result)
    end

    def render_websocket(body, *)
      @web_socket.send(body)
    end

    CHUNKED_TERM = "\r\n"
    CHUNKED_TAIL = "0#{CHUNKED_TERM}#{CHUNKED_TERM}"

    def render_chunked(body, *)
      data = [Rack::Utils.bytesize(body).to_s(16), CHUNKED_TERM, body, CHUNKED_TERM].join

      @body.call(data)
    end

    # Used by SSE
    def sse_event_id
      @sse_event_id ||= Time.now.to_i
    end

    def encode(string, encoding = 'UTF-8')
      string.respond_to?(:force_encoding) ? string.force_encoding(encoding) : string
    end

    protected

    def finish
      case transport
      when :chunked
        @body.call(CHUNKED_TAIL) if is_finishable?
      end

      super
    end

  end
end

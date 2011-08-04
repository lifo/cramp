module Cramp
  class Action < Abstract
    include PeriodicTimer
    include KeepConnectionAlive

    protected

    def render(body, *args)
      send(:"render_#{transport}", body, *args)
    end

    def send_initial_response(*)
      case transport
      when :long_polling
        # Dont send no initial response
      else
        super
      end
    end

    def respond_with
      case transport
      when :sse
        [200, {'Content-Type' => 'text/event-stream', 'Cache-Control' => 'no-cache', 'Connection' => 'keep-alive'}]
      else
        super
      end
    end

    def render_regular(body, *)
      @body.call(body)
    end

    def render_long_polling(data, *)
      status, headers = respond_with
      headers['Content-Length'] = data.size.to_s

      send_response(status, headers, @body)
      @body.call(data)

      finish
    end

    def render_sse(data, options = {})
      result = "id: #{sse_event_id}\n"
      result << "retry: #{options[:retry]}\n" if options[:retry]

      data.split(/\n/).each {|d| result << "data: #{d}\n" }
      result << "\n"

      @body.call(result)
    end

    def render_websocket(body, *)
      data = ["\x00", body, "\xFF"].map(&method(:encode)) * ''
      @body.call(data)
    end

    # Used by SSE
    def sse_event_id
      @sse_event_id ||= Time.now.to_i
    end

    def encode(string, encoding = 'UTF-8')
      string.respond_to?(:force_encoding) ? string.force_encoding(encoding) : string
    end

  end
end

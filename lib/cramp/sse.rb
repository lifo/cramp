module Cramp
  class SSE < Action
    self.transport = :sse

    def initialize(env)
      super

      if Faye::EventSource.eventsource?(env)
        error = "WARNING: EventSource headers not detected"
        Cramp.logger ? Cramp.logger.error(error) : $stderr.puts(error)
      end

      @eventsource = Faye::EventSource.new(env)
      @eventsource.on(:close) { |event| finish }
    end

    protected

    def render(data, options = {})
      @eventsource.send(data, options)
    end

    def send_initial_response(status, headers, body)
      # Faye handles this response.  We don't have to do anything
    end

  end
end

module Cramp
  class Websocket < Action
    self.transport = :websocket

    class << self
      def backend=(backend)
        raise "Websocket backend #{backend} is unknown" unless [:thin, :rainbows].include?(backend.to_sym)
        Faye::WebSocket.load_adapter(backend.to_s)
      end
    end

    def initialize(env)
      super

      if Faye::WebSocket.websocket?(env)
        @websocket = Faye::WebSocket.new(env)

        @websocket.on(:message) do |event|
          message = event.data
          _invoke_data_callbacks(message) if message.is_a?(String)
        end

        @websocket.on(:close) { |event| finish }
      else
        error = "WARNING: WebSocket headers not detected"
        Cramp.logger ? Cramp.logger.error(error) : $stderr.puts(error)
      end
    end

    protected

    def render(body, *)
      @websocket.send(body)
    end

    def send_initial_response(status, headers, body)
      # Faye handles this response.  We don't have to do anything
    end

  end
end

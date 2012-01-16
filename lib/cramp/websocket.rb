module Cramp
  class Websocket < Action
    self.transport = :websocket

    class << self
      def backend=(backend)
        raise "Websocket backend #{backend} is unknown" unless [:thin, :rainbows].include?(backend.to_sym)
        Faye::WebSocket.load_adapter(backend.to_s)
      end
    end

  end
end

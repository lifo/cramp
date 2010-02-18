module Cramp
  module Controller
    module WebsocketExtension
      WEBSOCKET_RECEIVE_CALLBACK = 'websocket.receive_callback'.freeze

      def websocket?
        @env['HTTP_CONNECTION'] == 'Upgrade' && @env['HTTP_UPGRADE'] == 'WebSocket'
      end

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

    class Websocket < Abstract

      include PeriodicTimer

      class_inheritable_accessor :on_data_callbacks, :instance_reader => false
      self.on_data_callbacks = []

      class << self
        def backend=(backend)
          raise "Websocket backend #{backend} is unknown" unless [:thin, :rainbows].include?(backend.to_sym)
          require "cramp/controller/websocket/#{backend}_backend.rb"
        end

        def on_data(*methods)
          self.on_data_callbacks += methods
        end
      end

      def process
        @env['websocket.receive_callback'] = method(:_on_data_receive)
        super
      end

      def render(body)
        @body.call("\x00#{body}\xff")
      end

      def _on_data_receive(data)
        data = data.slice(/\000([^\377]*)\377/).gsub(/^\x00|\xff$/, '')

        self.class.on_data_callbacks.each do |callback|
          EM.next_tick { send(callback, data) }
        end
      end

    end
  end
end

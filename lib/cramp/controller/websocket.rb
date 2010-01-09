module Cramp
  module Controller
    class Websocket < Abstract

      include PeriodicTimer

      class_inheritable_accessor :on_data_callbacks, :instance_reader => false
      self.on_data_callbacks = []

      class << self
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

        self.on_data_callbacks.each do |callback|
          EM.next_tick { send(callback, data) }
        end
      end

    end
  end
end

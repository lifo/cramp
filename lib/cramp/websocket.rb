module Cramp
  class Websocket < Abstract
    include PeriodicTimer

    # TODO : Websockets shouldn't need this in an ideal world
    include KeepConnectionAlive

    class_inheritable_accessor :on_data_callbacks, :instance_reader => false
    self.on_data_callbacks = []

    class << self
      def backend=(backend)
        raise "Websocket backend #{backend} is unknown" unless [:thin, :rainbows].include?(backend.to_sym)
        require "cramp/websocket/#{backend}_backend.rb"
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
      data = ["\x00", body, "\xFF"].map(&method(:encode)) * ''
      @body.call(data)
    end

    def _on_data_receive(data)
      data = data.split(/\000([^\377]*)\377/).select{|d| !d.empty? }.collect{|d| d.gsub(/^\x00|\xff$/, '') }
      self.class.on_data_callbacks.each do |callback|
        data.each do |message|
          EM.next_tick { send(callback, message) }
        end
      end
    end

    protected

    def encode(string, encoding = 'UTF-8')
      string.respond_to?(:force_encoding) ? string.force_encoding(encoding) : string
    end

  end
end

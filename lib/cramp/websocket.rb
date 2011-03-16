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
      @buffer = []
      @buffering = false
      @env['websocket.receive_callback'] = lambda {|data| data.each_char(&method(:_on_data_receive)) }

      super
    end

    def render(body)
      data = ["\x00", body, "\xFF"].map(&method(:encode)) * ''
      @body.call(data)
    end

    # _on_data_receive/encode methods derived from Faye - https://github.com/jcoglan/faye
    #
    # Copyright (c) 2009-2010 James Coglan
    # The MIT License
    def _on_data_receive(data)
      case data
      when "\x00" then
        @buffering = true
      when "\xFF" then
        message = encode(@buffer.join(''))

        self.class.on_data_callbacks.each do |callback|
          EM.next_tick { send(callback, message) }
        end

        @buffer = []
        @buffering = false
      else
        @buffer.push(data) if @buffering
      end
    end

    protected

    def encode(string, encoding = 'UTF-8')
      string.respond_to?(:force_encoding) ? string.force_encoding(encoding) : string
    end

  end
end

module Cramp
  module WebsocketExtension
    WEBSOCKET_RECEIVE_CALLBACK = 'websocket.receive_callback'.freeze

    def websocket?
      @env['HTTP_CONNECTION'] == 'Upgrade' && @env['HTTP_UPGRADE'] == 'WebSocket'
    end

    def websocket_upgrade_data
      location  = "ws://#{@env['HTTP_HOST']}#{@env['REQUEST_PATH']}"
      challenge = solve_challange(
        @env['HTTP_SEC_WEBSOCKET_KEY1'],
        @env['HTTP_SEC_WEBSOCKET_KEY2'],
        @env['rack.input'].read
      )

      upgrade =  "HTTP/1.1 101 Web Socket Protocol Handshake\r\n"
      upgrade << "Upgrade: WebSocket\r\n"
      upgrade << "Connection: Upgrade\r\n"
      upgrade << "Sec-WebSocket-Origin: #{@env['HTTP_ORIGIN']}\r\n"
      upgrade << "Sec-WebSocket-Location: #{location}\r\n\r\n"
      upgrade << challenge

      upgrade
    end

    def solve_challange(first, second, third)
      # Refer to 5.2 4-9 of the draft 76
      sum = 
        [extract_nums(first) / count_spaces(first)].pack("N*") +
        [extract_nums(second) / count_spaces(second)].pack("N*") +
        third
      Digest::MD5.digest(sum)
    end

    def extract_nums(string)
      string.scan(/[0-9]/).join.to_i
    end

    def count_spaces(string)
      string.scan(/ /).size 
    end
  end

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
      @body.call("\x00#{body}\xff")
    end

    def _on_data_receive(data)
      data = data.split(/\000([^\377]*)\377/).select{|d| !d.empty? }.collect{|d| d.gsub(/^\x00|\xff$/, '') }
      self.class.on_data_callbacks.each do |callback|
        data.each do |message|
          EM.next_tick { send(callback, message) }
        end
      end
    end
    
  end
end

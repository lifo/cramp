module Cramp
  class Websocket < Action
    self.transport = :websocket

    class << self
      def backend=(backend)
        raise "Websocket backend #{backend} is unknown" unless [:thin, :rainbows].include?(backend.to_sym)
        require "cramp/websocket/#{backend}_backend.rb"
      end
    end

  end
end

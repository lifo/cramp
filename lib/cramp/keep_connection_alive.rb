module Cramp
  module KeepConnectionAlive

    extend ActiveSupport::Concern
    include PeriodicTimer

    module ClassMethods
      def keep_connection_alive(options = {})
        options = { :every => 15 }.merge(options)
        periodic_timer :keep_connection_alive, options
      end
    end

    def keep_connection_alive
      @body.call " "
    end

  end
end

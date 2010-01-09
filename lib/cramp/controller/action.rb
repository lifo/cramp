module Cramp
  module Controller
    class Action < Abstract

      include PeriodicTimer
      include KeepConnectionAlive

      def render(body)
        @body.call(body)
      end

    end
  end
end

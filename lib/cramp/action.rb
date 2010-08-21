module Cramp
  class Action < Abstract

    include PeriodicTimer
    include KeepConnectionAlive

    def render(body)
      @body.call(body)
    end

  end
end

module Cramp
  class Action < Abstract
    include PeriodicTimer
    include KeepConnectionAlive

    protected

    def render(body, *args)
      @body.call(body)
    end

    def encode(string, encoding = 'UTF-8')
      string.respond_to?(:force_encoding) ? string.force_encoding(encoding) : string
    end

  end
end

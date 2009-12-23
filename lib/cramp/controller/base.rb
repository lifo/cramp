module Cramp
  module Controller
    class Base
      include Processing
      include PeriodicTimer
      include KeepConnectionAlive
      include BeforeStart

      def request
        @request ||= Rack::Request.new(@env)
      end

      def params
        @params ||= @env['usher.params']
      end

      def render(body)
        @body.call(body)
      end

    end
  end
end

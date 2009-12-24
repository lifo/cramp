module Cramp
  module Controller
    class Base < Abstract

      include PeriodicTimer
      include KeepConnectionAlive

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

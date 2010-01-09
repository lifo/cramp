module Cramp
  module Controller
    class Abstract

      include Callbacks

      ASYNC_RESPONSE = [-1, {}, []].freeze

      class << self
        def call(env)
          controller = new(env).process
        end
      end

      def initialize(env)
        @env = env
      end

      def process
        EM.next_tick { before_start }
        ASYNC_RESPONSE
      end

      def continue
        init_async_body

        status, headers = respond_with
        send_initial_response(status, headers, @body)

        EM.next_tick { start } if respond_to?(:start)
        EM.next_tick { on_start }
      end

      def respond_with
        [200, {'Content-Type' => 'text/html'}]
      end

      def init_async_body
        @body = Body.new

        if self.class.on_finish_callbacks.any?
          @body.callback { on_finish }
          @body.errback { on_finish }
        end
      end

      def finish
        @body.succeed
      end

      def send_initial_response(response_status, response_headers, response_body)
        EM.next_tick { @env['async.callback'].call [response_status, response_headers, response_body] }
      end

      def halt(status, headers = {}, halt_body = '')
        send_initial_response(status, headers, halt_body)
      end

      def request
        @request ||= Rack::Request.new(@env)
      end

      def params
        @params ||= @env['usher.params']
      end

    end
  end
end

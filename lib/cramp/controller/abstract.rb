module Cramp
  module Controller
    class Abstract

      include Callbacks

      class << self
        def call(env)
          controller = new(env).process
        end

        def set_default_response(status = 200, headers = DEFAULT_HEADERS)
          self.default_status = 200
          self.default_headers = headers
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
        send_initial_response(self.class.default_status, self.class.default_headers, @body)

        EM.next_tick { start } if respond_to?(:start)
        EM.next_tick { on_start }
      end

      def init_async_body
        @body = Body.new

        if self.class.on_finish_callbacks.any?
          @body.callback { on_finish }
          @body.errback { on_finish }
        end
      end

      def finish
        EM.next_tick { @body.succeed }
      end

      def send_initial_response(response_status, response_headers, response_body)
        EM.next_tick { @env['async.callback'].call [response_status, response_headers, response_body] }
      end

      def halt(status, headers = self.class.default_headers, halt_body = '')
        send_initial_response(status, headers, halt_body)
      end

    end
  end
end

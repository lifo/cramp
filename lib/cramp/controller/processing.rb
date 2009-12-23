module Cramp
  module Controller
    module Processing

      extend ActiveSupport::Concern

      ASYNC_RESPONSE = [-1, {}, []].freeze
      DEFAULT_STATUS = 200
      DEFAULT_HEADERS =  { 'Content-Type' => 'text/html' }.freeze

      module ClassMethods
        def call(env)
          controller = new(env).process
        end

        def set_default_response(status = 200, headers = DEFAULT_HEADERS)
          @default_status = 200
          @default_headers = headers
        end

        def default_status
          defined?(@default_status) ? @default_status : DEFAULT_STATUS
        end

        def default_headers
          defined?(@default_headers) ? @default_headers : DEFAULT_HEADERS
        end
      end

      def initialize(env)
        @env = env
      end

      def process
        ASYNC_RESPONSE
      end

      def continue
        init_async_body
        send_initial_response(self.class.default_status, self.class.default_headers, @body)

        EM.next_tick { start } if respond_to?(:start)
      end

      def init_async_body
        @body = Body.new
        @body.callback { on_finish }
        @body.errback { on_finish }
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

      def on_finish
      end

    end
  end
end

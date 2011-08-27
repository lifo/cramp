require 'active_support/core_ext/hash/keys'

module Cramp
  class Abstract
    include Callbacks
    include FiberPool

    class_attribute :transport
    self.transport = :regular

    class << self
      def call(env)
        new(env).process
      end
    end

    def initialize(env)
      @env = env
      @finished = false

      @_state = :init
    end

    def process
      EM.next_tick { before_start }
      throw :async
    end

    protected

    def continue
      init_async_body
      send_headers

      @_state = :started
      EM.next_tick { on_start }
    end

    def send_headers
      status, headers = build_headers
      send_initial_response(status, headers, @body)
    rescue StandardError, LoadError, SyntaxError => exception
      handle_exception(exception)
    end

    def build_headers
      status, headers = respond_to?(:respond_with, true) ? respond_with.dup : [200, {'Content-Type' => 'text/html'}]
      headers['Connection'] ||= 'keep-alive'
      [status, headers]
    end

    def init_async_body
      @body = Body.new

      if self.class.on_finish_callbacks.any?
        @body.callback { on_finish }
        @body.errback { on_finish }
      end
    end

    def finished?
      !!@finished
    end

    def finish
      @body.succeed if is_finishable?
    ensure
      @_state = :finished
      @finished = true
    end

    def send_initial_response(response_status, response_headers, response_body)
      send_response(response_status, response_headers, response_body)
    end

    def halt(status, headers = {}, halt_body = '')
      send_response(status, headers, halt_body)
    end

    def send_response(response_status, response_headers, response_body)
      @env['async.callback'].call [response_status, response_headers, response_body]
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      @params ||= request.params.update(route_params).symbolize_keys
    end

    def route_params
      @env['router.params'] || {}
    end

    private

    def is_finishable?
      !finished? && @body && !@body.closed?
    end

  end
end

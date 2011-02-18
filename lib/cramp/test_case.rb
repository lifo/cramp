require 'active_support'
require 'active_support/test_case'

module Cramp
  class TestCase < ::ActiveSupport::TestCase

    setup :create_request

    def create_request
      @request = Rack::MockRequest.new(app)
    end

    def get(path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      headers = headers.merge('async.callback' => callback)

      EM.run do
        catch(:async) { @request.get(path, headers) }
      end
    end

    def get_body(path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      response_callback = proc {|response| response[-1].each {|chunk| callback.call(chunk) } }
      headers = headers.merge('async.callback' => response_callback)

      EM.run do
        catch(:async) { @request.get(path, headers) }
      end
    end

    def get_body_chunks(path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      count = options.delete(:count) || 1

      stopping = false
      chunks = []

      get_body(path, options, headers) do |body_chunk|
        chunks << body_chunk unless stopping

        if chunks.count >= count
          stopping = true
          callback.call(chunks) if callback
          EM.next_tick { EM.stop }
        end
      end
    end

    def app
      raise "Please define a method called 'app' returning an async Rack Application"
    end

    def stop
      EM.stop
    end
  end
end
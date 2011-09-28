require 'active_support'
require 'active_support/test_case'

module Cramp
  class TestCase < ::ActiveSupport::TestCase

    setup :create_request

    def create_request
      @request = Rack::MockRequest.new(app)
    end

    def get(path, opts={}, headers={}, &block)     request(:get, path, opts, headers, &block)     end
    def post(path, opts={}, headers={}, &block)    request(:post, path, opts, headers, &block)    end
    def put(path, opts={}, headers={}, &block)     request(:put, path, opts, headers, &block)     end
    def delete(path, opts={}, headers={}, &block)  request(:delete, path, opts, headers, &block)  end
    def options(path, opts={}, headers={}, &block) request(:options, path, opts, headers, &block) end

    def request(method, path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      headers = headers.merge('async.callback' => callback)

      EM.run do
        catch(:async) { @request.request(method, path, headers) }
      end
    end

    def get_body(path, opts={}, headers={}, &block)     request_body(:get, path, opts, headers, &block)     end
    def post_body(path, opts={}, headers={}, &block)    request_body(:post, path, opts, headers, &block)    end
    def put_body(path, opts={}, headers={}, &block)     request_body(:put, path, opts, headers, &block)     end
    def delete_body(path, opts={}, headers={}, &block)  request_body(:delete, path, opts, headers, &block)  end
    def options_body(path, opts={}, headers={}, &block) request_body(:options, path, opts, headers, &block) end

    def request_body(method, path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      response_callback = proc do |response|
        # 'halt' returns a String, not an async Body object
        if response.last.is_a? String
          callback.call(response.last)
        else
          response.last.each {|chunk| callback.call(chunk) }
        end
      end
      headers = headers.merge('async.callback' => response_callback)

      EM.run do
        catch(:async) { @request.request(method, path, headers) }
      end
    end


    def get_body_chunks(path, opts={}, headers={}, &block)     request_body_chunks(:get, path, opts, headers, &block)     end
    def post_body_chunks(path, opts={}, headers={}, &block)    request_body_chunks(:post, path, opts, headers, &block)    end
    def put_body_chunks(path, opts={}, headers={}, &block)     request_body_chunks(:put, path, opts, headers, &block)     end
    def delete_body_chunks(path, opts={}, headers={}, &block)  request_body_chunks(:delete, path, opts, headers, &block)  end
    def options_body_chunks(path, opts={}, headers={}, &block) request_body_chunks(:options, path, opts, headers, &block) end

    def request_body_chunks(method, path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      count = options.delete(:count) || 1

      stopping = false
      chunks = []

      request_body(method, path, options, headers) do |body_chunk|
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


module Cramp
  class Chunked < Action
    self.transport = :chunked

    class_attribute :default_chunked_headers
    self.default_chunked_headers = {'Transfer-Encoding' => 'chunked', 'Connection' => 'keep-alive'}

    protected

    CHUNKED_TERM = "\r\n"
    CHUNKED_TAIL = "0#{CHUNKED_TERM}#{CHUNKED_TERM}"

    def render(body, *)
      data = [ Rack::Utils.bytesize(body).to_s(16), CHUNKED_TERM, body, CHUNKED_TERM ].join

      @body.call(data)
    end

    def build_headers
      status, headers = respond_to?(:respond_with, true) ? respond_with : [200, {}]

      headers = headers.merge(self.default_chunked_headers)
      headers['Content-Type'] ||= 'text/html'
      headers['Cache-Control'] ||= 'no-cache'

      [status, headers]
    end

    def finish
      @body.call(CHUNKED_TAIL) if is_finishable?

      super
    end

  end
end

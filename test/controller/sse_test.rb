require 'test_helper'

class SseTest < Cramp::TestCase

  class LiveController < Cramp::SSE
    on_start :go_sse

    def go_sse
      render "Hello World"
      render "Hello non-message event type", :event => :different
      finish
    end
  end

  def app
    LiveController
  end

  def test_headers
    get '/' do |status, headers, body|
      assert_equal 101, status
      assert_kind_of Faye::EventSource::Stream, body
      stop
    end
  end

  def test_body
    get_body_chunks '/', :count => 3 do |chunks|
      assert_equal chunks[1], "data: Hello World\r\n\r\n"
      assert_equal chunks[2], "event: different\r\ndata: Hello non-message event type\r\n\r\n"
    end
  end

end

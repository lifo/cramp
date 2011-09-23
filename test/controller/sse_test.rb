require 'test_helper'

class SseTest < Cramp::TestCase

  class LiveController < Cramp::Action
    self.transport = :sse
    on_start :go_sse

    def go_sse
      render "Hello World"
      render "Nothing", :retry => 10
      render "Hello non-message event type", :event => :different
      finish
    end
  end

  def app
    LiveController
  end

  def test_headers
    get '/' do |status, headers, body|
      assert_equal 200, status
      assert_equal "text/event-stream", headers["Content-Type"]
      assert_kind_of Cramp::Body, body

      stop
    end
  end

  def test_body
    get_body_chunks '/', :count => 3 do |chunks|
      # chunk1 = id: 1297999043\ndata: Hello World
      first_chunk = chunks[0].split("\n")
      assert first_chunk[0] =~ /\Aid: \d+\Z/, first_chunk.inspect
      assert first_chunk[1] =~ /\Adata: Hello World\Z/, first_chunk.inspect

      second_chunk = chunks[1].split("\n")
      assert_equal "retry: 10", second_chunk[1]
      assert_equal "data: Nothing", second_chunk[2]
      
      third_chunk = chunks[2].split("\n")
      assert_equal "event: different", third_chunk[1]
      assert_equal "data: Hello non-message event type", third_chunk[2]
    end
  end

end

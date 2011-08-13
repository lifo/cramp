require 'test_helper'

class ChunkedTransportTest < Cramp::TestCase

  class ChunkedAction < Cramp::Action
    self.transport = :chunked
    on_start :send_chunks

    def send_chunks
      render "Hello"
      render "World!"
      finish
    end
  end

  def app
    ChunkedAction
  end

  def test_headers
    get '/' do |status, headers, body|
      assert_equal 200, status

      assert_equal "chunked", headers["Transfer-Encoding"]
      assert_equal "text/html", headers["Content-Type"]
      assert_equal "no-cache", headers["Cache-Control"]

      assert_kind_of Cramp::Body, body

      EM.stop
    end
  end

  def test_body
    get_body_chunks '/', :count => 3 do |chunks|
      assert_equal ["5\r\nHello\r\n", "6\r\nWorld!\r\n", "0\r\n\r\n"], chunks
    end
  end

end

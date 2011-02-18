require 'test_helper'

class FiberPoolTest < Cramp::TestCase

  class SexyTime < Cramp::Action
    cattr_accessor :logs
    self.logs = []

    use_fiber_pool :size => 10 do |pool|
      pool.generic_callbacks << proc { SexyTime.logs << "WHAT WHAT WHAT" }
    end

    on_start :go_borat
    periodic_timer :finish_soon

    def go_borat
      render "Kazakhstannn in a Fiber!"
    end

    def finish_soon
      render "I joke! I laughe!"
    end
  end

  def app
    SexyTime
  end

  def test_headers
    get '/' do |status, headers, body|
      assert_equal 200, status
      assert_equal "text/html", headers["Content-Type"]
      assert_kind_of Cramp::Body, body

      stop
    end
  end

  def test_headers
    get '/' do |status, headers, body|
      assert_equal 200, status
      assert_equal "text/html", headers["Content-Type"]
      assert_kind_of Cramp::Body, body

      stop
    end
  end

  def test_body
    get_body_chunks '/', :count => 2 do |chunks|
      assert_equal "Kazakhstannn in a Fiber!", chunks[0]
      assert_equal "I joke! I laughe!", chunks[1]
    end

    assert_equal ["WHAT WHAT WHAT", "WHAT WHAT WHAT"], SexyTime.logs
  end
end

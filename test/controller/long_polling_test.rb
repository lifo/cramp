require 'test_helper'

class LongPollingTest < Cramp::TestCase

  class PollController < Cramp::Action
    self.transport = :long_polling

    on_start :foot_long_pole
    on_finish :poll_done

    def foot_long_pole
      render "Hello World"
    end

    cattr_accessor :logs
    self.logs = []
    def poll_done
      self.logs << 'Poll done'
    end
  end

  def app
    PollController
  end

  def test_body
    get_body '/' do |body|
      assert_equal 'Hello World', body
      stop
    end
  end

  def test_render_finishes_response
    get('/') { EM.next_tick { stop } }
    assert_equal 'Poll done', PollController.logs[0]
  end
end

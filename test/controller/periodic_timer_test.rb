require 'test_helper'

class PeriodicTimerTest < Cramp::TestCase

  class SendDataController < Cramp::Action
    periodic_timer :send_data, :every => 0

    def send_data
      render "Hello"
    end
  end

  class FinishingTimerController < Cramp::Action
    periodic_timer :finish_soon, :every => 0

    def finish_soon
      render "done"
      finish
    end
  end

  App = HttpRouter.new do
    add('/send_data').to(SendDataController)
    add('/finishing_timer').to(FinishingTimerController)
  end

  def app
    App
  end

  def test_send_data_periodic_timer
    get_body_chunks '/send_data', :count => 10 do |chunks|
      assert_equal 10, chunks.size
      assert_equal ["Hello"], chunks.uniq
    end
  end

  def test_finishing_timer
    get '/finishing_timer' do |response|
      body = response[-1]
      assert ! body.closed?

      body.each do |chunk|
        assert body.closed?
        EM.stop
      end

    end
  end

end

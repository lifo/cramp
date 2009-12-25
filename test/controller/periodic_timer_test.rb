require 'test_helper'

class PeiodicTimerTest < Cramp::Controller::TestCase

  class SendDataController < Cramp::Controller::Base
    periodic_timer :send_data, :every => 0

    def send_data
      render "Hello"
    end
  end

  class FinishingTimerController < Cramp::Controller::Base
    periodic_timer :finish_soon, :every => 0

    def finish_soon
      render "done"
      finish
    end
  end

  App = Usher::Interface.for(:rack) do
    add('/send_data').to(SendDataController)
    add('/finishing_timer').to(FinishingTimerController)
  end

  def app
    App
  end

  def test_send_data_periodic_timer
    get_body_chunks '/send_data', :count => 10 do |chunks|
      assert_equal 10, chunks.size
      assert ["Hello"], chunks.uniq
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
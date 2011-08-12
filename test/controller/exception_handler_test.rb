require 'test_helper'

class ExceptionHandlerTest < Cramp::TestCase

  class BadAction < Cramp::Action
    before_start :raise_before_start
    on_start :raise_on_start

    on_finish :raise_on_finish

    def raise_before_start
      raise "before_start" if params[:state] == 'before_start'
      yield
    end

    def raise_on_start
      raise "on_start" if params[:state] == 'on_start'
      finish
    end

    def raise_on_start
      raise "on_start" if params[:state] == 'on_start'
    end
  end

  class BadTimer < Cramp::Action
    periodic_timer :raise_error, :every => 0

    def raise_error
      raise "Bad Timer"
    end
  end

  class BadRespondWith < Cramp::Action
    def respond_with
      raise "Bad Response"
    end
  end

  def app
    HttpRouter.new do
      add('/bad_timer').to(BadTimer)
      add('/bad_respond_with').to(BadRespondWith)
      add('/:state').to(BadAction)
    end
  end

  def test_exception_in_before_start
    get '/before_start' do |status, headers, body|
      assert_equal 500, status
      assert_equal 'Something went wrong', body

      EM.stop
    end
  end

  def test_exception_in_on_start
    get '/on_start' do |status, headers, body|
      # Sadly, headers are already sent out before the exception occurs
      assert_equal 200, status
      body.callback { EM.stop }
    end
  end

  def test_exception_in_timer
    get '/bad_timer' do |status, headers, body|
      assert_equal 200, status
      body.callback { EM.stop }
    end
  end

  def test_bad_respond_with
    get '/bad_respond_with' do |status, headers, body|
      assert_equal 500, status
      assert_equal 'Something went wrong', body

      EM.stop
    end
  end

end
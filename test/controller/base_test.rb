require 'test_helper'

class BaseTest < Cramp::Controller::TestCase

  class WelcomeController < Cramp::Controller::Action
    def start
      render "Hello World"
      finish
    end
  end

  def app
    WelcomeController
  end

  def test_headers
    get '/' do |status, headers, body|
      assert_equal 200, status
      assert_equal "text/html", headers["Content-Type"]
      assert_kind_of Cramp::Controller::Body, body

      stop
    end
  end

  def test_body
    get_body '/' do |body_chunk|
      assert_equal "Hello World", body_chunk

      stop
    end
  end
end
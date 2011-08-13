require 'test_helper'

class BaseTest < Cramp::TestCase

  class WelcomeController < Cramp::Action
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
      assert_equal "keep-alive", headers["Connection"]
      assert_kind_of Cramp::Body, body

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

class CustomHeadersTest < Cramp::TestCase

  class CustomHeadersController < Cramp::Action
    def respond_with
      [201, {'Content-Type' => 'application/json'}]
    end

    def start
      render "Hello World"
      finish
    end
  end

  def app
    CustomHeadersController
  end

  def test_headers
    get '/' do |status, headers, body|
      assert_equal 201, status
      assert_equal "application/json", headers["Content-Type"]
      assert_kind_of Cramp::Body, body

      stop
    end
  end
end
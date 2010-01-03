require 'test_helper'

class KeepAliveTest < Cramp::Controller::TestCase

  class KeepAliveController < Cramp::Controller::Action
    keep_connection_alive :every => 0
  end

  def app
    KeepAliveController
  end

  def test_keep_alive
    get_body_chunks '/', :count => 2 do |chunks|
      assert " ", chunks[0]
      assert " ", chunks[1]
    end
  end

end
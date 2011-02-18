require 'test_helper'

class WebSocketTest < Cramp::TestCase

  class WebSocketAction < Cramp::Websocket
    cattr_accessor :logs
    self.logs = []

    on_data :write_logs

    def write_logs(data)
      self.logs << data
    end
  end

  def app
    WebSocketAction
  end

  def test_sending_data_over_websocket
    env = Rack::MockRequest.env_for('/')
    env['async.callback'] = proc {|resp| }

    EM.run do
      catch(:async) { app.call(env) }
      env['websocket.receive_callback'].call("\000Hello Websock!\377")
      EM.stop
    end

    assert_equal ['Hello Websock!'], WebSocketAction.logs
  end
end
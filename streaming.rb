require 'rubygems'

$: << File.join(File.dirname(__FILE__), "lib")
require 'cramp/controller'

class StreamController < Cramp::Controller::Base
  def start
    @n ||= 0
    @streamer = EventMachine::PeriodicTimer.new(1) { send_data }
  end

  def on_finish
    @streamer.cancel
  end

  def send_data
    @n += 1
    render ["Hello World", "\n"]

    finish if @n == 10
  end
end

Rack::Handler::Thin.run StreamController, :Port => 3000

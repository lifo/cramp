require File.join(File.dirname(__FILE__), "../vendor/gems/environment")
$: << File.join(File.dirname(__FILE__), "../lib")

require 'cramp/controller'

Cramp::Controller::Websocket.backend = :rainbows

class WelcomeController < Cramp::Controller::Websocket
  periodic_timer :send_hello_world, :every => 2
  on_data :received_data

  def received_data(data)
    if data =~ /fuck/
      render "You cant say fuck in here"
      finish
    else
      render "Got your #{data}"
    end
  end

  def send_hello_world
    render "Hello from the Server!"
  end
end

# rainbows -E deployment -c rainbows.conf hello_world.ru
run WelcomeController

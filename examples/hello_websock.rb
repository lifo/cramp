require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'thin'

Cramp::Websocket.backend = :thin

class WelcomeController < Cramp::Websocket
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

Thin::Logging.trace = true

Rack::Handler::Thin.run WelcomeController, :Port => 3000

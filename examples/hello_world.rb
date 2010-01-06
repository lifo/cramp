require 'rubygems'

$: << File.join(File.dirname(__FILE__), "../lib")
require 'cramp/controller'

class WelcomeController < Cramp::Controller::Action
  def start
    render "Hello World"
    finish
  end
end

Rack::Handler::Thin.run WelcomeController, :Port => 3000

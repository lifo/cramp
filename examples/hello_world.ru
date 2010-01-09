require File.join(File.dirname(__FILE__), "../vendor/gems/environment")
$: << File.join(File.dirname(__FILE__), "../lib")

require 'cramp/controller'

class WelcomeController < Cramp::Controller::Action
  def start
    render "Hello World"
    finish
  end
end

# rainbows -E deployment -c rainbows.conf hello_world.ru
run WelcomeController

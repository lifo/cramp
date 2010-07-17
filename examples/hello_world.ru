require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp/controller'

class WelcomeController < Cramp::Controller::Action
  def start
    render "Hello World"
    finish
  end
end

# rainbows -E deployment -c rainbows.conf hello_world.ru
run WelcomeController

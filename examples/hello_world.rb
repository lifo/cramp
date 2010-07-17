require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp/controller'
require 'thin'

class WelcomeController < Cramp::Controller::Action
  def start
    render "Hello World"
    finish
  end
end

Rack::Handler::Thin.run WelcomeController, :Port => 3000

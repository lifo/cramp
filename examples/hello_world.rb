require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'thin'

class WelcomeController < Cramp::Action
  def start
    render "Hello World"
    finish
  end
end

Rack::Handler::Thin.run WelcomeController, :Port => 3000

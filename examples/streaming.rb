require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'thin'

class StreamController < Cramp::Action
  periodic_timer :send_data, :every => 1
  periodic_timer :check_limit, :every => 2

  def start
    @limit = 0
  end

  def send_data
    render ["Hello World", "\n"]
  end

  def check_limit
    @limit += 1
    finish if @limit > 1
  end

end

Rack::Handler::Thin.run StreamController, :Port => 3000

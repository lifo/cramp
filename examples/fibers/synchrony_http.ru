require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'em-http-request'
require 'em-synchrony/em-http'

class SynchronyController < Cramp::Action
  use_fiber_pool

  def start
    page = EventMachine::HttpRequest.new("http://m.onkey.org").get
    render page.response
    finish
  end
end

# bundle exec thin -V -R examples/fibers/synchrony_http.ru start
# bundle exec rainbows -E deployment -c examples/rainbows.conf examples/fibers/synchrony_http.ru
run SynchronyController

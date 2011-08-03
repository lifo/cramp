###################################################################################################
#   Implements the example described in http://www.html5rocks.com/tutorials/eventsource/basics    #
###################################################################################################

require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'http_router'
require 'active_support/json'
require 'async_rack'

class TimeController < Cramp::Action
  self.transport = :sse

  on_start :send_latest_time
  periodic_timer :send_latest_time, :every => 2

  def send_latest_time
    data = {'time' => Time.now.to_i}.to_json

    # render data, :retry => 10
    render data
  end
end

routes = HttpRouter.new do
  add('/sse').to(TimeController)
end

file_server = Rack::File.new(File.join(File.dirname(__FILE__), 'public'))

# bundle exec thin -V -R examples/sse/server.ru start
use AsyncRack::CommonLogger
run Rack::Cascade.new([file_server, routes])

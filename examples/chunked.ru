require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'thin'

class Chunked < Cramp::Action
  self.transport = :chunked

  on_start :send_data
  periodic_timer :close_stream, :every => 3

  def send_data
    3.times { render Time.now.to_s }
  end

  def close_stream
    render "That's all folks!"
    finish
  end
end

# You can test this from the terminal using curl
# $ curl -N http://0.0.0.0:3000/

# bundle exec thin -V -R examples/chunked.ru start
run Chunked

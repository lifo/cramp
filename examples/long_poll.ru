require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'thin'

class LazyController < Cramp::LongPolling
  on_start :init_limit
  periodic_timer :check_limit, :every => 1

  def init_limit
    @limit = 0
  end

  def check_limit
    @limit += 1

    if @limit > 20
      puts "And the wait is over !!!"

      # Send back a response to the client. Terminate the request.
      render "Hello World!"
    else
      puts "You must wait"
    end
  end

  def respond_with
    [200, {'Content-Type' => 'text/plain'}]
  end

end

# bundle exec thin -V -R examples/long_poll.ru start
run LazyController

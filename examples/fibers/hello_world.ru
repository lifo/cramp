require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'

class FibersController < Cramp::Action
  use_fiber_pool :size => 200

  def start
    render "Hello World"
    finish
  end
end

# bundle exec thin -V -R examples/fibers/hello_world.ru start
# bundle exec rainbows -E deployment -c examples/rainbows.conf examples/fibers/hello_world.ru
run FibersController

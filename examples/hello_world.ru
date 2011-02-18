require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'

class WelcomeController < Cramp::Action
  def start
    render "Hello World"
    finish
  end
end

# bundle exec thin -V -R examples/hello_world.ru start
# bundle exec rainbows -E deployment -c examples/rainbows.conf examples/hello_world.ru
run WelcomeController

require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'http_router'
require 'erubis'

if defined?(Rainbows)
  puts "Using Rainbows backend for websockets"
  Cramp::Websocket.backend = :rainbows
else
  puts "Using Thin backend for websockets"
  Cramp::Websocket.backend = :thin
end

module ChatRamp
  class HomeAction < Cramp::Action
    template_path = File.join(File.dirname(__FILE__), 'views/index.erb')
    @@template = Erubis::Eruby.new(File.read(template_path))

    def start
      render @@template.result(binding)
      finish
    end
  end

  class SocketAction < Cramp::Websocket
    @@users = Set.new

    on_start :user_connected
    on_finish :user_left
    on_data :message_received

    def user_connected
      @@users << self
    end

    def user_left
      @@users.delete self
    end

    def message_received(data)
      puts "Connected users :#{@@users.size.inspect}"
      @@users.each {|u| u.render data }
    end
  end
end

routes = HttpRouter.new do
  add('/').to(ChatRamp::HomeAction)
  add('/socket').to(ChatRamp::SocketAction)
end

# bundle exec rainbows -c examples/rainbows.conf examples/chat_websocket/config.ru
# bundle exec thin -V -R examples/chat_websocket/config.ru start
run routes

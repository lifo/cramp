require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'http_router'
require 'sinatra/async'

class Stream < Cramp::Action
  def start
    render "Hello!"
    finish
  end
end

class Home < Sinatra::Base
  register Sinatra::Async
  enable :inline_templates

  aget '/' do
    body <<-BODY
      <html>
        <head>
          <title>Cramp meets Sinatra</title>
        </head>

        <body>
          <a href='/cramp'>Say hi to Cramp</a>
        </body>
      </html>
    BODY
  end
end

routes = HttpRouter.new do
  add('/cramp').to(Stream)
end

# bundle exec thin -V -R examples/sinatra_async.ru start
# bundle exec rainbows -E deployment -c examples/rainbows.conf examples/sinatra_async.ru
run Rack::Cascade.new([routes, Home])

require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'http_router'
require 'yajl'
require 'active_support/json'
require 'active_support/core_ext/array/wrap'

class ChatController < Cramp::Action
  self.transport = :long_polling

  @@connected = {}
  @@buffer = [ {'message' => ['lifo', 'hello']} ]
  @@channel = EM::Channel.new

  on_start :check_incoming_data
  on_start :init_sessions

  on_start :subscribe
  on_finish :unsubscribe

  # This won't even be called if the request is terminated within 5 seconds
  periodic_timer :refresh_connection, :every => 5

  def init_sessions
    if !params[:verified]
      render encode_messages(params[:session_id])
    elsif !@@connected[params[:session_id]]
      @@connected[params[:session_id]] = true
      render encode_messages({'buffer' => @@buffer})
    end
  end

  def check_incoming_data
    if request.post?
      decode_messages(request.POST["data"]).each do |message|
        data = {'message' => [params[:session_id], message]}
        @@buffer.push(data)
        @@channel.push(data)
      end

      render "ok"
    elsif request.options?
      render "ok"
    end
  end

  def subscribe
    @sid = @@channel.subscribe do |message|
      if(message['message'][0] != params[:session_id])
        render encode_messages(message)
      end
    end
  end

  def unsubscribe
    @@channel.unsubscribe(@sid) if @sid
  end

  def refresh_connection
    render ''
  end

  def respond_with
    headers = {}

    headers['Content-Type'] = 'text/plain; charset=UTF-8'
    headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN']
    headers['Access-Control-Allow-Credentials'] = 'true'

    [200, headers]
  end

  def encode_messages(messages)
    data = ''

    Array.wrap(messages).each do |message|
      message = "~j~#{message.to_json}" unless message.is_a?(String)  
      data << "~m~#{message.length}~m~#{message}"
    end

    data
  end

  # Taken from https://github.com/markjeee/Socket.IO-rack
  def decode_messages(data)
    data = data.dup.force_encoding('UTF-8') if RUBY_VERSION >= "1.9"
    messages = []

    loop do
      case data.slice!(0,3)
      when '~m~'
        size, data = data.split('~m~', 2)
        size = size.to_i
  
        case data[0,3]
        when '~j~'
          messages.push Yajl::Parser.parse(data[3, size - 3])
        when '~h~'
          # let's have our caller process the message
          messages.push data[0, size]
        else
          messages.push data[0, size]
        end
  
        # let's slize the message
        data.slice!(0, size)
      when nil, ''
        break
      else
        raise "Unsupported frame type #{data[0,3]}"
      end
    end
  
    messages
  end

end

routes = HttpRouter.new do
  # add('/cramp/xhr-polling/*wtf').to(ChatController)
  add('/cramp/xhr-polling/:session_id').to(ChatController)
  add('/cramp/xhr-polling/:session_id/:verified').to(ChatController)
  add('/cramp/xhr-polling/:session_id/send').to(ChatController)
  # add('/cramp/xhr-polling/*args').to(ChatController)
end

file_server = Rack::File.new(File.join(File.dirname(__FILE__), 'public'))

# bundle exec thin -V -R examples/socketio/server.ru start
# bundle exec rainbows -c examples/rainbows.conf examples/socketio/server.ru
run Rack::Cascade.new([file_server, routes])

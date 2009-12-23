require 'rubygems'

$: << File.join(File.dirname(__FILE__), "../lib")
require 'cramp/controller'

class HomeController < Cramp::Controller::Base
  # Optional - These are the default headers
  set_default_response 200, 'Content-Type' => 'text/html'

  def before_start
    if params[:password] != 'foo'
      halt 401, {}, "Bad Password"
    else
      continue
    end
  end

  def start
    EM.add_timer(1) { render "Hello World"; finish }
  end

  def on_finish
    # asycn body closed
  end

end

routes = Usher::Interface.for(:rack) do
  add('/(:password)').to(HomeController)
end

Rack::Handler::Thin.run routes, :Port => 3000

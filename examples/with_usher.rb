require File.join(File.dirname(__FILE__), "../vendor/gems/environment")
$: << File.join(File.dirname(__FILE__), "../lib")

require 'cramp/controller'

class HomeController < Cramp::Controller::Action
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

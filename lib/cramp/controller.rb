require 'cramp'
require 'rack'

module Cramp
  module Controller
    autoload :Action, "cramp/controller/action"
    autoload :Websocket, "cramp/controller/websocket"
    autoload :Body, "cramp/controller/body"
    autoload :PeriodicTimer, "cramp/controller/periodic_timer"
    autoload :KeepConnectionAlive, "cramp/controller/keep_connection_alive"
    autoload :Abstract, "cramp/controller/abstract"
    autoload :Callbacks, "cramp/controller/callbacks"
    autoload :TestCase, "cramp/controller/test_case"
  end
end
